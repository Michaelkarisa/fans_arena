import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {ParsedQs} from "qs";
import sizeOf from 'image-size';
import 'moment';
import axios from 'axios';
import * as corsLib from 'cors';
import * as express from 'express';
import * as bodyParser from 'body-parser';
import { DocumentReference} from "firebase-admin/firestore";
import { Recipient, EmailParams, MailerSend, Sender } from 'mailersend';

// Initialize MailerSend
const mailersend = new MailerSend({
    apiKey: 'mlsn.3dad6a8c701c8f8f4fa4a290f899d8c244b6bb8a03fe6befd0b43ce6ce18e948',
});

 //import { Timestamp } from "firebase-admin/firestore";
//import { user } from "firebase-functions/v1/auth";

/**
 * Converts parsed query string parameters to a typed object.
 * @param {ParsedQs} parsedQs The parsed query string parameters.
 * @return {Record<string, string | string[] | undefined>}
 */
function convertParsedQs(parsedQs: ParsedQs):
Record<string, string | string[] | undefined> {
  const result: Record<string, string | string[] | undefined> = {};
  for (const key in parsedQs) {
    if (Object.prototype.hasOwnProperty.call(parsedQs, key)) {
      const value = parsedQs[key];
      result[key] = Array.isArray(value) ? value.map(String) :
        typeof value === "string" ? value : undefined;
    }
  }
  return result;
}


admin.initializeApp();
// posts
exports.getPostsForFollowedUsers = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams = convertParsedQs(request.query);
    const currentUserUid = queryParams["uid"] as string;

    if (!currentUserUid) {
      response.status(400).json({ error: "User ID is required" });
      return;
    }

    const followingUids = [currentUserUid];

    // Helper function to collect UIDs from a Firestore snapshot
    const collectUids = (snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
      snapshot.forEach((doc) => {
        const followingData = doc.data()[key] as { userId: string }[];
        followingData.forEach((item) => {
          if (item.userId) {
            followingUids.push(item.userId);
          }
        });
      });
    };
    const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
      snapshot.forEach((doc) => {
        const clubsTeamTable = doc.data()[key] || [];
        const clubsteam = doc.data()['clubsteam'] || [];
        if (clubsTeamTable[1]) {
          const fieldName = clubsTeamTable[1].fn;
          clubsteam.forEach((clubItem: { [key: string]: string }) => {
            if (clubItem[fieldName]) {
              followingUids.push(clubItem[fieldName]);
            }
          });
        }
      });
    };
    
    // Collecting following UIDs
    const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
    collectUids(followingSnapshot, 'following');

    const clubSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
    collectUids(clubSnapshot, 'clubs');

    const profesSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
    collectUids(profesSnapshot, 'professionals');

    const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("fans").get();
    collectUids(fromclubSnapshot, 'fans');

    const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("fans").get();
    collectUids(fromprofeSnapshot, 'fans');

    const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("clubsteam").get();
    collectUids1(fromclubteamSnapshot, 'clubsTeamTable');

    const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("trustedaccounts").get();
    collectUids(fromprofetSnapshot, 'accounts');

    const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("club").get();
    fromprofeclubSnapshot.forEach((doc) => {
      if (doc.id) {
        followingUids.push(doc.id);
      }
    });

    // Remove duplicates and undefined values
    const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);

    // Split the followingUids array into chunks of 30
    const chunkArray = (array: string[], size: number) => {
      const result = [];
      for (let i = 0; i < array.length; i += size) {
        result.push(array.slice(i, i + size));
      }
      return result;
    };

    const uidChunks = chunkArray(uniqueUids, 30);
    const postsPromises = uidChunks.map(async (uids) => {
      const postsQuery = await admin.firestore().collection("posts")
        .where("authorId", "in", uids)
        .orderBy("createdAt", "desc")
        .limit(4)
        .get();

      return postsQuery.docs.map((doc) => ({
        postId: doc.id,
        createdAt: doc.data().createdAt,
        authorId: doc.data().authorId,
        location: doc.data().location,
        genre: doc.data().genre,
        captionUrl: doc.data().captionUrl,
        commenting: doc.data().commenting,
        likes: doc.data().likes,
      }));
    });
    const postsArray = await Promise.all(postsPromises);
    const posts = ([] as any[]).concat(...postsArray);
    const enrichedPosts = await Promise.all(posts.map(async (post) => {
      const userData = await fetchUserData(post.authorId);
      const captionUrl=await getImageAspectRatios(post.captionUrl)
      return {
        ...post,
        author:userData,
        captionUrl:captionUrl,
      };
    }));
    response.json({ posts: enrichedPosts });
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({ error: "Failed to get posts: " + error});
  }
});

interface ImageAspectRatio {
  url: string;
  width: number | null;
  height:number| null;
}

async function getImageAspectRatios(captionUrl: any[]): Promise<ImageAspectRatio[]> {
  const fetchImageData = async (url: string): Promise<Buffer> => {
    const response = await axios.get(url, { responseType: 'arraybuffer' });
    return Buffer.from(response.data);
  };
  const promises = captionUrl.map(async (data:{url:string,caption:string}) => {
    try {
      const imageData = await fetchImageData(data.url);
      const dimensions = sizeOf(imageData);
      if (dimensions.width && dimensions.height) {
        return {
            caption:data.caption,
            url:data.url,
           height: dimensions.height,
           width: dimensions.width,
        };
      } else {
        throw new Error(`Could not retrieve dimensions for image: ${data.url}`);
      }
    } catch (error) {
      console.error(`Error processing image at ${data.url}:`, error);
      return {
        caption:data.caption,
        url:data.url,
        height: 1,
        width: 1,
      };
    }
  });
  try {
    const aspectRatios = await Promise.all(promises);
    return aspectRatios;
  } catch (error) {
    throw new Error(`Error processing image aspect ratios: ${error}`);
  }
}


// Fanstv
exports.getFansTv =
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string, string | string[]
    | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;

    if (!currentUserUid) {
      response.status(400).json({error: "User ID is required"});
      return;
    }

    const followingUids: string[] = [currentUserUid];
    const collectUids = (snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
      snapshot.forEach((doc) => {
        const followingData = doc.data()[key] as { userId: string }[];
        followingData.forEach((item) => {
          if (item.userId) {
            followingUids.push(item.userId);
          }
        });
      });
    };
    const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
      snapshot.forEach((doc) => {
        const clubsTeamTable = doc.data()[key] || [];
        const clubsteam = doc.data()['clubsteam'] || [];
        if (clubsTeamTable[1]) {
          const fieldName = clubsTeamTable[1].fn;
          clubsteam.forEach((clubItem: { [key: string]: string }) => {
            if (clubItem[fieldName]) {
              followingUids.push(clubItem[fieldName]);
            }
          });
        }
      });
    };
    
    // Collecting following UIDs
    const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
    collectUids(followingSnapshot, 'following');

    const clubSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
    collectUids(clubSnapshot, 'clubs');

    const profesSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
    collectUids(profesSnapshot, 'professionals');

    const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("fans").get();
    collectUids(fromclubSnapshot, 'fans');

    const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("fans").get();
    collectUids(fromprofeSnapshot, 'fans');

    const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("clubsteam").get();
    collectUids1(fromclubteamSnapshot, 'clubsTeamTable');

    const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("trustedaccounts").get();
    collectUids(fromprofetSnapshot, 'accounts');

    const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("club").get();
    fromprofeclubSnapshot.forEach((doc) => {
      if (doc.id) {
        followingUids.push(doc.id);
      }
    });
    const postsQuery = await admin.firestore().collection("FansTv")
      .orderBy("createdAt", "desc")
      .limit(4)
      .get();
    const posts1 = postsQuery.docs.map((doc) => ({
       postId: doc.id,
      createdAt: doc.data().createdAt,
      authorId: doc.data().authorId,
      location: doc.data().location,
      genre: doc.data().genre,
      caption: doc.data().caption,
      thumbnail:doc.data().thumbnail,
      url: doc.data().url,
      commenting: doc.data().commenting,
      likes: doc.data().likes,
    }));
    const posts = await Promise.all(posts1.map(async (post) => {
      // Fetch user data for each post's authorId
      const userData = await fetchUserData(post.authorId);
      // Merge user data into the post object
      return {
          ...post,
          author:userData       
      };
  }));
    response.json({posts});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});
async function fetchUserData(authorId: string):
 Promise<{profileImage: string, username: string,
  collectionName:string,location:string,motto:string, userId:string,docRef:DocumentReference,country:string,token:string,timestamp:any}> {
  let username:string='';
  let imageurl:string='';
  let collectionName='';
  let location:string='';
  let motto:string='';
  let token:string='';
  let doc:any;
  let createdAt:any;
  let country:string="Kenya";
  if(authorId){
  const clubSnapshot = await admin.firestore()
  .collection('Clubs').doc(authorId).get();
  if (clubSnapshot.exists) {
      const clubData = clubSnapshot.data();
      username = clubData?.Clubname;
      imageurl = clubData?.profileimage;
      location = clubData?.Location;
      createdAt= clubData?.createdAt;
      motto= clubData?.Motto;
      collectionName = 'Club';
      token = clubData?.fcmToken;
      doc=clubSnapshot.ref;
      country=clubData?.country;
  } else {
      const professionalSnapshot = await admin.firestore()
      .collection('Professionals').doc(authorId).get();
      if (professionalSnapshot.exists) {
          const professionalData = professionalSnapshot.data();
          username = professionalData?.Stagename;
         imageurl = professionalData?.profileimage;
         location = professionalData?.Location;
         createdAt= professionalData?.createdAt;
          collectionName = 'Professional';
          token = professionalData?.fcmToken;
          doc=professionalSnapshot.ref;
          country=professionalData?.country;
      } else {
          const fanSnapshot = await admin.firestore()
          .collection('Fans').doc(authorId).get();
          if (fanSnapshot.exists) {
              const fanData = fanSnapshot.data();
              username = fanData?.username;
              imageurl = fanData?.profileimage;
              location = fanData?.location;
              createdAt= fanData?.createdAt;
              collectionName = 'Fan';
              token = fanData?.fcmToken;
              doc=fanSnapshot.ref;
              country=fanData?.country;
          }else{
            const leagueSnapshot = await admin.firestore()
            .collection('Leagues').doc(authorId).get();
            if (leagueSnapshot.exists) {
                const leagueData = leagueSnapshot.data();
                username = leagueData?.leaguename;
                imageurl = leagueData?.profileimage;
                location = leagueData?.location;
                createdAt= leagueData?.createdAt;
                collectionName = 'League';
                doc=leagueSnapshot.ref;
                country=leagueData?.country;
            }else{
              username='';
              imageurl='';
              location='';
              collectionName="";
              motto="";
            }
          }
      }
  }}
  return {
      profileImage:imageurl,
      username: username,
      collectionName:collectionName,
      location:location,
      motto:motto,
      userId:authorId,
      docRef:doc,
      token:token,
      timestamp:createdAt,
      country:country,
  };
}

async function fetchLeagueyears(leagueId: string):
 Promise<{leagues:string[], }> {
  let leagues:string[]=[];
  if(leagueId){
            const leagueSnapshot = await admin.firestore()
            .collection('Leagues').doc(leagueId)
            .collection('year').orderBy('timestamp','desc').get();
          leagueSnapshot.docs.map((doc)=>{
          leagues.push(doc.id);
          });
        }   
  return {
     leagues:leagues,
  };
}
// more posts
exports.getmorePostsForFollowedUsers = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
  .onRequest(async (request, response) => {
    try {
      const queryParams: Record<string,
      string | string[] | undefined> = convertParsedQs(request.query);
     const currentUserUid: string | undefined = queryParams["uid"] as string;
     const lastdocId: string | undefined = 
     queryParams["lastdocId"] as string;
     if (!currentUserUid||!lastdocId) {
       response.status(400).json({error: "uid and lastdocId is required"});
       return;
     }
     const followingUids = [currentUserUid];
     const collectUids = (snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
      snapshot.forEach((doc) => {
        const followingData = doc.data()[key] as { userId: string }[];
        followingData.forEach((item) => {
          if (item.userId) {
            followingUids.push(item.userId);
          }
        });
      });
    };
    const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
      snapshot.forEach((doc) => {
        const clubsTeamTable = doc.data()[key] || [];
        const clubsteam = doc.data()['clubsteam'] || [];
        if (clubsTeamTable[1]) {
          const fieldName = clubsTeamTable[1].fn;
          clubsteam.forEach((clubItem: { [key: string]: string }) => {
            if (clubItem[fieldName]) {
              followingUids.push(clubItem[fieldName]);
            }
          });
        }
      });
    };
    
    // Collecting following UIDs
    const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
    collectUids(followingSnapshot, 'following');

    const clubSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
    collectUids(clubSnapshot, 'clubs');

    const profesSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
    collectUids(profesSnapshot, 'professionals');

    const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("fans").get();
    collectUids(fromclubSnapshot, 'fans');

    const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("fans").get();
    collectUids(fromprofeSnapshot, 'fans');

    const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("clubsteam").get();
    collectUids1(fromclubteamSnapshot, 'clubsTeamTable');

    const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("trustedaccounts").get();
    collectUids(fromprofetSnapshot, 'accounts');

    const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("club").get();
    fromprofeclubSnapshot.forEach((doc) => {
      if (doc.id) {
        followingUids.push(doc.id);
      }
    });
     // Split the followingUids array into chunks of 30
     const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);
     const chunkArray = (array: string | any[], size: number) => {
      const result = [];
      for (let i = 0; i < array.length; i += size) {
        result.push(array.slice(i, i + size));
      }
      return result;
    };
    const doc=await admin.firestore().collection("posts").doc(lastdocId).get();
    const uidChunks = chunkArray(uniqueUids, 30);
    const postsPromises = uidChunks.map(async (uids) => {
      const postsQuery = await admin.firestore().collection("posts")
        .where("authorId", "in", uids)
        .orderBy("createdAt", "desc")
        .startAfter(doc)
        .limit(4)
        .get();

      return postsQuery.docs.map((doc) => ({
        postId: doc.id,
        createdAt: doc.data().createdAt,
        authorId: doc.data().authorId,
        location: doc.data().location,
        genre: doc.data().genre,
        captionUrl: doc.data().captionUrl,
        commenting: doc.data().commenting,
        likes: doc.data().likes,
      }));
    });
    const postsArray = await Promise.all(postsPromises);
    const posts = ([] as any[]).concat(...postsArray);
    const enrichedPosts = await Promise.all(posts.map(async (post) => {
      const userData = await fetchUserData(post.authorId);
      const captionUrl=await getImageAspectRatios(post.captionUrl)
      return {
        ...post,
        author:userData,
        captionUrl:captionUrl,
      };
    }));
    response.json({ posts: enrichedPosts });
    } catch (error) {
      console.error("Error getting posts:", error);
      response.status(500).json({error: "Failed to get posts"+error});
    }
  });

  // more posts
exports.getmoreFansTv = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
  .onRequest(async (request, response) => {
    try {
      const queryParams: Record<string,
      string | string[] | undefined> = convertParsedQs(request.query);
     const currentUserUid: string | undefined = queryParams["uid"] as string;
     const lastdocId: string | undefined = 
     queryParams["lastdocId"] as string;
 
     if (!currentUserUid||!lastdocId) {
       response.status(400).json({error: "uid and lastdocId is required"});
       return;
     }
      const followingUids: string[] = [currentUserUid];
      const collectUids = (snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
        snapshot.forEach((doc) => {
          const followingData = doc.data()[key] as { userId: string }[];
          followingData.forEach((item) => {
            if (item.userId) {
              followingUids.push(item.userId);
            }
          });
        });
      };
      const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
        snapshot.forEach((doc) => {
          const clubsTeamTable = doc.data()[key] || [];
          const clubsteam = doc.data()['clubsteam'] || [];
          if (clubsTeamTable[1]) {
            const fieldName = clubsTeamTable[1].fn;
            clubsteam.forEach((clubItem: { [key: string]: string }) => {
              if (clubItem[fieldName]) {
                followingUids.push(clubItem[fieldName]);
              }
            });
          }
        });
      };
      
      // Collecting following UIDs
      const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
      collectUids(followingSnapshot, 'following');
  
      const clubSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
      collectUids(clubSnapshot, 'clubs');
  
      const profesSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
      collectUids(profesSnapshot, 'professionals');
  
      const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("fans").get();
      collectUids(fromclubSnapshot, 'fans');
  
      const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("fans").get();
      collectUids(fromprofeSnapshot, 'fans');
  
      const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("clubsteam").get();
      collectUids1(fromclubteamSnapshot, 'clubsTeamTable');
  
      const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("trustedaccounts").get();
      collectUids(fromprofetSnapshot, 'accounts');
  
      const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("club").get();
      fromprofeclubSnapshot.forEach((doc) => {
        if (doc.id) {
          followingUids.push(doc.id);
        }
      });
    const lastDoc =await admin.firestore()
    .collection('FansTv').doc(lastdocId).get();
      let postsQuery = admin.firestore().collection("FansTv")
        .orderBy("createdAt", "desc");
        postsQuery = postsQuery.startAfter(lastDoc);
      postsQuery = postsQuery.limit(3);

      const postsQuerySnapshot = await postsQuery.get();

      const posts1 = postsQuerySnapshot.docs.map((doc) => ({
        postId: doc.id,
        createdAt: doc.data().createdAt,
        authorId: doc.data().authorId,
        location: doc.data().location,
        genre: doc.data().genre,
        caption: doc.data().caption,
        url: doc.data().url,
        thumbnail:doc.data().thumbnail,
        commenting: doc.data().commenting,
        likes: doc.data().likes,
      }));
      const posts = await Promise.all(posts1.map(async (post) => {
        // Fetch user data for each post's authorId
        const userData = await fetchUserData(post.authorId);
        // Merge user data into the post object
        return {
            ...post,
            author:userData
            
        };
    }));
      response.json({posts});
    } catch (error) {
      console.error("Error getting posts:", error);
      response.status(500).json({error: "Failed to get posts"+error});
    }
  });
// stories
exports.getStoryForFollowedUsers =
  functions.runWith({
    timeoutSeconds: 540 // Adjust the timeout value as needed
  }).https.onRequest(async (request, response) => {
    try {
      const queryParams: Record<string, string | string[]
      | undefined> = convertParsedQs(request.query);
      const currentUserUid: string | undefined = queryParams["uid"] as string;

      if (!currentUserUid) {
        response.status(400).json({error: "User ID is required"});
        return;
      }

      const followingUids:String[] = [];
      const collectUids = (snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
        snapshot.forEach((doc) => {
          const followingData = doc.data()[key] as { userId: string }[];
          followingData.forEach((item) => {
            if (item.userId) {
              followingUids.push(item.userId);
            }
          });
        });
      };
      const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
        snapshot.forEach((doc) => {
          const clubsTeamTable = doc.data()[key] || [];
          const clubsteam = doc.data()['clubsteam'] || [];
          if (clubsTeamTable[1]) {
            const fieldName = clubsTeamTable[1].fn;
            clubsteam.forEach((clubItem: { [key: string]: string }) => {
              if (clubItem[fieldName]) {
                followingUids.push(clubItem[fieldName]);
              }
            });
          }
        });
      };
      
      // Collecting following UIDs
      const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
      collectUids(followingSnapshot, 'following');
  
      const clubSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
      collectUids(clubSnapshot, 'clubs');
  
      const profesSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
      collectUids(profesSnapshot, 'professionals');
  
      const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("fans").get();
      collectUids(fromclubSnapshot, 'fans');
  
      const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("fans").get();
      collectUids(fromprofeSnapshot, 'fans');
  
      const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("clubsteam").get();
      collectUids1(fromclubteamSnapshot, 'clubsTeamTable');
  
      const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("trustedaccounts").get();
      collectUids(fromprofetSnapshot, 'accounts');
  
      const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("club").get();
      fromprofeclubSnapshot.forEach((doc) => {
        if (doc.id) {
          followingUids.push(doc.id);
        }
      });
 
     // Split the followingUids array into chunks of 30
     const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);
     const chunkArray = (array: string | any[], size: number) => {
      const result = [];
      for (let i = 0; i < array.length; i += size) {
        result.push(array.slice(i, i + size));
      }
      return result;
    };

    const uidChunks = chunkArray(uniqueUids, 30);  
      const postsPromises = uidChunks.map(async (uids) => {
        const postsQuery = await admin.firestore().collection("Story")
        .where("authorId", "in", uids)
        .orderBy("createdAt", "desc")
        .limit(8)
        .get();
  
        return postsQuery.docs.map((doc) => ({
          createdAt: doc.data().createdAt,
          authorId: doc.data().authorId,
          story: doc.data().story,
          StoryId:doc.id,
        }));
      });
  
      const postsArray = await Promise.all(postsPromises);
      const posts = ([] as any[]).concat(...postsArray);
  
      const enrichedPosts = await Promise.all(posts.map(async (post) => {
        const userData = await fetchUserData(post.authorId);
        return {
          ...post,
          author:userData
        };
      }));
  
      response.json({story: enrichedPosts });
    } catch (error) {
      console.error("Error getting story:", error);
      response.status(500).json({error: "Failed to get posts"+error});
    }
  });

// more storys

exports.getmoreStoryForFollowedUsers = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
  .onRequest(async (request, response) => {
    try {
      const queryParams: Record<string,
       string | string[] | undefined> = convertParsedQs(request.query);
      const currentUserUid: string | undefined = queryParams["uid"] as string;
      const lastdocId: string | undefined = 
      queryParams["lastdocId"] as string;
  
      if (!currentUserUid||!lastdocId) {
        response.status(400).json({error: "uid and lastdocId is required"});
        return;
      }

    
      const followingUids:String[] = [];
      const collectUids = (snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
        snapshot.forEach((doc) => {
          const followingData = doc.data()[key] as { userId: string }[];
          followingData.forEach((item) => {
            if (item.userId) {
              followingUids.push(item.userId);
            }
          });
        });
      };
      const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
        snapshot.forEach((doc) => {
          const clubsTeamTable = doc.data()[key] || [];
          const clubsteam = doc.data()['clubsteam'] || [];
          if (clubsTeamTable[1]) {
            const fieldName = clubsTeamTable[1].fn;
            clubsteam.forEach((clubItem: { [key: string]: string }) => {
              if (clubItem[fieldName]) {
                followingUids.push(clubItem[fieldName]);
              }
            });
          }
        });
      };
      
      // Collecting following UIDs
      const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
      collectUids(followingSnapshot, 'following');
  
      const clubSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
      collectUids(clubSnapshot, 'clubs');
  
      const profesSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
      collectUids(profesSnapshot, 'professionals');
  
      const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("fans").get();
      collectUids(fromclubSnapshot, 'fans');
  
      const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("fans").get();
      collectUids(fromprofeSnapshot, 'fans');
  
      const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("clubsteam").get();
      collectUids1(fromclubteamSnapshot, 'clubsTeamTable');
  
      const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("trustedaccounts").get();
      collectUids(fromprofetSnapshot, 'accounts');
  
      const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("club").get();
      fromprofeclubSnapshot.forEach((doc) => {
        if (doc.id) {
          followingUids.push(doc.id);
        }
      });
     // Split the followingUids array into chunks of 30
     const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);
     const chunkArray = (array: string | any[], size: number) => {
      const result = [];
      for (let i = 0; i < array.length; i += size) {
        result.push(array.slice(i, i + size));
      }
      return result;
    };
    const doc=await admin.firestore().collection("Story").doc(lastdocId).get();
    const uidChunks = chunkArray(uniqueUids, 30);  
      const postsPromises = uidChunks.map(async (uids) => {
        const postsQuery = await admin.firestore().collection("Story")
        .where("authorId", "in", uids)
        .orderBy("createdAt", "desc")
        .startAfter(doc)
        .limit(4)
        .get();
  
        return postsQuery.docs.map((doc) => ({
          createdAt: doc.data().createdAt,
          authorId: doc.data().authorId,
          story: doc.data().story,
          StoryId:doc.id,
        }));
      });
  
      const postsArray = await Promise.all(postsPromises);
      const posts = ([] as any[]).concat(...postsArray);
  
      const enrichedPosts = await Promise.all(posts.map(async (post) => {
        const userData = await fetchUserData(post.authorId);
        return {
          ...post,
          author:userData
        };
      }));
  
      response.json({story: enrichedPosts });
    } catch (error) {
      console.error("Error getting story:", error);
      response.status(500).json({error: "Failed to get posts"+error});
    }
  });

// leagues

exports.getLeaguesForUser = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string, string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;

    if (!currentUserUid) {
      response.status(400).json({ error: "User ID is required" });
      return;
    }

    const followingUids: string[] = [currentUserUid];
    const leagueUids: Set<string> = new Set();

    // Fetch clubs from 'Fans' collection
    const fanClubSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("clubs").get();
    fanClubSnapshot.forEach((doc) => {
      const followingData = doc.data().clubs as { userId: string }[];
      followingData.forEach((club) => {
        followingUids.push(club.userId);
      });
    });

    const fanProfessionalSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("professionals").get();
    fanProfessionalSnapshot.forEach((doc) => {
      const followingData = doc.data().professionals as { userId: string }[];
      followingData.forEach((club) => {
        followingUids.push(club.userId);
      });
    });

    // Fetch clubs from 'Professionals' collection
    const professionalClubSnapshot = await admin.firestore()
      .collection("Professionals").doc(currentUserUid)
      .collection("club").get();
    professionalClubSnapshot.forEach((doc) => {
      followingUids.push(doc.id);
    });

    // Fetch all league IDs
    const allLeaguesSnapshot = await admin.firestore()
      .collection("Leagues").get();

    for (const leagueDoc of allLeaguesSnapshot.docs) {
      const leagueId = leagueDoc.id;

      const latestYearDocQuery = await admin.firestore()
        .collection("Leagues").doc(leagueId)
        .collection("year").orderBy("timestamp", "desc").limit(1).get();

      if (!latestYearDocQuery.empty) {
        const latestYearDocId = latestYearDocQuery.docs[0].id;
        const latestYearData = latestYearDocQuery.docs[0].data();

        // Ensure leagueTable[1] exists and extract fn field value
        if (latestYearData.leagueTable && latestYearData.leagueTable[1]) {
          const fnField = latestYearData.leagueTable[1].fn;
        const yearPostsQuery = await admin.firestore()
          .collection("Leagues").doc(leagueId)
          .collection("year").doc(latestYearDocId)
          .collection("clubs").get();

        yearPostsQuery.docs.forEach((doc) => {
          const clubData = doc.data().clubs as { [key: string]: string }[];
          clubData.forEach((club) => {
            if (followingUids.includes(club[fnField])) {
              leagueUids.add(leagueId);
            }
          });
        });
      }}

      const postsQuery = await admin.firestore()
        .collection("Leagues").doc(leagueId)
        .collection("subscribers").get();

      postsQuery.forEach((doc) => {
        const subscriberData = doc.data().subscribers as { userId: string }[];
        subscriberData.forEach((subscriber) => {
          if (subscriber.userId === currentUserUid) {
            leagueUids.add(leagueId);
          }
        });
      });
    }

    const allLeagues: {
      createdAt: string;
      accountType: string;
      authorId: string;
      leagueId: string;
      leagues: string[];
      genre: string;
      location: string;
      leaguename: string;
      profileimage: string;
      authorname?: string;
      authorurl?: string;
    }[] = [];
    
    const uniqueLeagueIds = Array.from(leagueUids);

    for (const uid of uniqueLeagueIds) {
      const leagueDoc = await admin.firestore()
        .collection("Leagues").doc(uid).get();
      if (leagueDoc.exists) {
        const leagueData = leagueDoc.data();
        if (leagueData) {
          const data = await fetchLeagueyears(leagueDoc.id);
          const data1 = await fetchUserData(leagueData.authorId);
          const league = {
            createdAt: leagueData.createdAt,
            authorId: leagueData.authorId,
            leagueId: leagueDoc.id,
            genre: leagueData.genre,
            location: leagueData.location,
            leaguename: leagueData.leaguename,
            profileimage: leagueData.profileimage,
            author:data1,
            accountType: leagueData.accountType,
            leagues: data.leagues as string[],
          };
          allLeagues.push(league);
        }
      }
    }

    response.json({ leagues: allLeagues });
  } catch (error) {
    console.error("Error getting leagues:", error);
    response.status(500).json({ error: "Failed to get leagues" + error });
  }
});

//get league
exports.getLeague =
  functions.runWith({
    timeoutSeconds: 540 // Adjust the timeout value as needed
  }).https.onRequest(async (request, response) => {
    try {
      const queryParams: Record<string,
       string | string[] | undefined> = convertParsedQs(request.query);
      const leagueId: string | 
      undefined = queryParams["leagueId"] as string;

      if (!leagueId) {
        response.status(400).json({error: "leagueId is required"});
        return;
      }
     // const allleagueUids: string[] = [];
      //const lleagueUids: string[] = [];
      const leagueDoc = await admin.firestore()
      .collection("Leagues").doc(leagueId).get();
  
      if (leagueDoc.exists) {
        const leagueData = leagueDoc.data();
    
        if (leagueData) {
          const data1 = await fetchUserData(leagueData.authorId);
          const data = await fetchLeagueyears(leagueDoc.id);
          const league = {
            createdAt: leagueData.createdAt,
            authorId: leagueData.authorId,
            leagueId: leagueDoc.id,
            genre: leagueData.genre,
            location: leagueData.location,
            leaguename: leagueData.leaguename,
            profileimage: leagueData.profileimage,
            accountType: leagueData.accountType,
            author:data1,
            leagues: data.leagues as string[],
          };
    
          // Respond with the league data
          response.json({league});
        }
      }
    } catch (error) {
      console.error("Error getting leagues:", error);
      response.status(500).json({error: "Failed to get league"+error});
    }
  });
  //getmyleague
  exports.getmyLeague =
  functions.runWith({
    timeoutSeconds: 540 // Adjust the timeout value as needed
  }).https.onRequest(async (request, response) => {
    try {
      const queryParams: Record<string,
       string | string[] | undefined> = convertParsedQs(request.query);
      const authorId: string | 
      undefined = queryParams["authorId"] as string;

      if (!authorId) {
        response.status(400).json({error: "authorId is required"});
        return;
      }
     // const allleagueUids: string[] = [];
      //const lleagueUids: string[] = [];
      const leagueDoc = await admin.firestore()
      .collection("Leagues").where('authorId','==',authorId).limit(1).get();
      if (leagueDoc.docs[0].exists) {
        const doc=leagueDoc.docs[0];
        const leagueData = doc.data();
    
        if (leagueData) {
          const data1 = await fetchUserData(leagueData.authorId);
          const data = await fetchLeagueyears(doc.id);
          const league = {
            createdAt: leagueData.createdAt,
            authorId: leagueData.authorId,
            leagueId: doc.id,
            genre: leagueData.genre,
            location: leagueData.location,
            leaguename: leagueData.leaguename,
            profileimage: leagueData.profileimage,
            accountType:leagueData.accountType,
            author: data1,
            leagues: data.leagues as string[],
          };
          // Respond with the league data
          response.json({league});
        }
      }
    } catch (error) {
      console.error("Error getting leagues:", error);
      response.status(500).json({error: "Failed to get posts"+error});
    }
  });
  //posts send notification
exports.sendPostNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).firestore
  .document('posts/{postId}')
  .onCreate(async (snap) => {
    try {
      const post = snap.data();
      const currentUserUid = post.authorId;

      // Send notification to author's followers
      const followingUids = new Set([currentUserUid]);
      let imageurl = '';

      const collectUids = (snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
        snapshot.forEach((doc) => {
          const followingData = doc.data()[key] as { userId: string }[];
          followingData.forEach((item) => {
            if (item.userId) {
              followingUids.add(item.userId);
            }
          });
        });
      };
      const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
        snapshot.forEach((doc) => {
          const clubsTeamTable = doc.data()[key] || [];
          const clubsteam = doc.data()['clubsteam'] || [];
          if (clubsTeamTable[1]) {
            const fieldName = clubsTeamTable[1].fn;
            clubsteam.forEach((clubItem: { [key: string]: string }) => {
              if (clubItem[fieldName]) {
                followingUids.add(clubItem[fieldName]);
              }
            });
          }
        });
      };
      
      // Collecting following UIDs
      const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
      collectUids(followingSnapshot, 'following');
  
      const clubSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
      collectUids(clubSnapshot, 'clubs');
  
      const profesSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
      collectUids(profesSnapshot, 'professionals');
  
      const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("fans").get();
      collectUids(fromclubSnapshot, 'fans');
  
      const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("fans").get();
      collectUids(fromprofeSnapshot, 'fans');
  
      const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("clubsteam").get();
      collectUids1(fromclubteamSnapshot, 'clubsTeamTable');
  
      const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("trustedaccounts").get();
      collectUids(fromprofetSnapshot, 'accounts');
  
      const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("club").get();
      fromprofeclubSnapshot.forEach((doc) => {
        if (doc.id) {
          followingUids.add(doc.id);
        }
      });

      // Fetch user data for current user
      const sendClubNotification = async (userData: any) => {
        if (userData !== undefined) {
          const token = userData.token;
          const userId= userData.userId;
          if (token) {
            if (userId === currentUserUid) {
              const message = {
                notification: {
                  title: 'New post',
                  body: 'New post upload complete',
                },
                data: {
                  click_action: "FLUTTER_NOTIFICATION_CLICK",
                  tab: "/Posts",
                  d: post.postId || '' // Ensure this field is defined
                },
                android: {
                  notification: {
                    sound: "default",
                    image: imageurl || '', // Ensure this field is defined
                  },
                },
                token,
              };
              await sendANotification(message);
            }
          }
        }
      };
      const userData = await fetchUserData(currentUserUid);
      if (post.captionUrl && post.captionUrl.length > 0) {
        imageurl = post.captionUrl[0].url || ''; // Ensure this field is defined
      }
      await sendClubNotification(userData);

      const useruids = Array.from(followingUids);
      const registrationTokens:string[] = [];
      const usersData:{userId: string;
        userRef:DocumentReference;}[] = [];

      // Fetch FCM tokens for all following users
      const promises = useruids.map(async (followerId) => {
        const userData= await fetchUserData(followerId);
        if (userData !== undefined) {
          registrationTokens.push(userData.token);
          usersData.push({
            userId:userData.userId,
            userRef:userData.docRef,
          });
        }
      });

      await Promise.all(promises);
     

      // Subscribe the devices to the topic
      const topic = 'posts_notifications' + currentUserUid;
      const message = {
        notification: {
          title: 'New post',
          body: `Check out the latest post from ${userData.username}`,
        },
        topic: topic,
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          tab: "/Posts",
          d: post.postId || '' // Ensure this field is defined
        },
        android: {
          notification: {
            sound: "default",
            image: imageurl || '', // Ensure this field is defined
          },
        },
      };
      const uniquetokens = Array.from(new Set(registrationTokens)).filter(Boolean);
      await sendAllNotification(uniquetokens,message,topic);
      await addAllNotifications(usersData, currentUserUid, post.postId, "added a new post");
      return true;
    } catch (error) {
      console.error('Error sending notifications:', error);
      return false;
    }
  });



exports.sendFansTvNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).firestore
.document('FansTv/{postId}')
.onCreate(async (snap) => {
  try {
    const post = snap.data();
    const currentUserUid= post.authorId;

      // Send notification to author's followers
      const followingUids = new Set([currentUserUid]);
      let imageurl = '';
      let name = '';

      const collectUids = (snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
        snapshot.forEach((doc) => {
          const followingData = doc.data()[key] as { userId: string }[];
          followingData.forEach((item) => {
            if (item.userId) {
              followingUids.add(item.userId);
            }
          });
        });
      };
      const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
        snapshot.forEach((doc) => {
          const clubsTeamTable = doc.data()[key] || [];
          const clubsteam = doc.data()['clubsteam'] || [];
          if (clubsTeamTable[1]) {
            const fieldName = clubsTeamTable[1].fn;
            clubsteam.forEach((clubItem: { [key: string]: string }) => {
              if (clubItem[fieldName]) {
                followingUids.add(clubItem[fieldName]);
              }
            });
          }
        });
      };
      
      // Collecting following UIDs
      const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
      collectUids(followingSnapshot, 'following');
  
      const clubSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
      collectUids(clubSnapshot, 'clubs');
  
      const profesSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
      collectUids(profesSnapshot, 'professionals');
  
      const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("fans").get();
      collectUids(fromclubSnapshot, 'fans');
  
      const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("fans").get();
      collectUids(fromprofeSnapshot, 'fans');
  
      const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("clubsteam").get();
      collectUids1(fromclubteamSnapshot, 'clubsTeamTable');
  
      const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("trustedaccounts").get();
      collectUids(fromprofetSnapshot, 'accounts');
  
      const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("club").get();
      fromprofeclubSnapshot.forEach((doc) => {
        if (doc.id) {
          followingUids.add(doc.id);
        }
      });
      // Fetch user data for current user
    

      // Send notification to the other club
      const sendClubNotification = async (userData: any) => {
        if (userData !== undefined) {
          const userId=userData.userId;
          imageurl = userData.profileImage;
          name = userData.username;
          const token =userData.token;
          if (token) {
            if (userId=== currentUserUid) {
              const message = {
                notification: {
                  title: 'New video',
                  body: `New video upload complete`,
              },
                data: {
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                    tab: "/FansTv",
                    d:post.postId
                },
                android: {
                    notification: {
                        sound: "default",
                        image: '',
                    },
                },
                token,
            };
              await sendANotification(message);
          }
        }} 
      };

        const userData=await fetchUserData(currentUserUid);
        await sendClubNotification(userData);
       

      const useruids = Array.from(followingUids);
      const registrationTokens:string[] = [];
      const usersData: {
        userId: string;
        userRef:DocumentReference;
       }[]=[];
      // Fetch FCM tokens for all following users
      const promises = useruids.map(async (followerId) => {
        const userData= await fetchUserData(followerId);
        if (userData !== undefined) {
          registrationTokens.push(userData.token);
          usersData.push({
            userId:userData.userId,
            userRef:userData.docRef,
          });
        }
      });

      await Promise.all(promises);

      // Subscribe the devices to the topic
      const topic = 'fanstv_notifications' + currentUserUid;
      const message = {
        notification: {
          title: 'New video',
          body: `Check out the latest video from ${name}`,
      },
        topic: topic,
        data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            tab: "/FansTv",
            d:post.postId
        },
        android: {
            notification: {
                sound: "default",
                image: imageurl,
            },
        },
    };
    const uniquetokens = Array.from(new Set(registrationTokens)).filter(Boolean);
    await sendAllNotification(uniquetokens,message,topic);
      await addAllNotifications(usersData,currentUserUid,post.postId,"added a new video",);
      return true;
    } catch (error) {
      console.error('Error sending notifications:', error);
      return false;
    }
  });


  //matches send notification
const getMessaging = admin.messaging();

exports.sendMatchNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).firestore
  .document('Matches/{matchId}')
  .onCreate(async (snap) => {
    try {
      const post = snap.data();
      const currentUserUid = post.authorId;
      const club1Id = post.club1Id;
      const club2Id = post.club2Id;

      // Send notification to author's followers
      const followingUids = new Set([currentUserUid]);
      //let imageurl = '';
      //let name = '';

      const collectUids = (snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
        snapshot.forEach((doc) => {
          const followingData = doc.data()[key] as { userId: string }[];
          followingData.forEach((item) => {
            if (item.userId) {
              followingUids.add(item.userId);
            }
          });
        });
      };
      const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
        snapshot.forEach((doc) => {
          const clubsTeamTable = doc.data()[key] || [];
          const clubsteam = doc.data()['clubsteam'] || [];
          if (clubsTeamTable[1]) {
            const fieldName = clubsTeamTable[1].fn;
            clubsteam.forEach((clubItem: { [key: string]: string }) => {
              if (clubItem[fieldName]) {
                followingUids.add(clubItem[fieldName]);
              }
            });
          }
        });
      };
      
      // Collecting following UIDs
      const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
      collectUids(followingSnapshot, 'following');
  
      const clubSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
      collectUids(clubSnapshot, 'clubs');
  
      const profesSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
      collectUids(profesSnapshot, 'professionals');
  
      const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("fans").get();
      collectUids(fromclubSnapshot, 'fans');
  
      const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("fans").get();
      collectUids(fromprofeSnapshot, 'fans');
  
      const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("clubsteam").get();
      collectUids1(fromclubteamSnapshot, 'clubsTeamTable');
  
      const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("trustedaccounts").get();
      collectUids(fromprofetSnapshot, 'accounts');
  
      const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("club").get();
      fromprofeclubSnapshot.forEach((doc) => {
        if (doc.id) {
          followingUids.add(doc.id);
        }
      });
      // Fetch user data for current user
    
      const userDataA= await fetchUserData(currentUserUid);
      // Send notification to the other club
      const sendClubNotification = async (userData: any) => {
        try{
        if (userData !== undefined) {
          const userId=userData.userId;
          const token =userData.token;
          if (token) {
            if (userId === currentUserUid) {
              const message = {
                notification: {
                  title: 'New match',
                  body: `You have succeded in adding a new match`,
                },
                data: {
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                    tab: "/Matches",
                    d:post.matchId
                },
                android: {
                    notification: {
                        sound: "default",
                        image:"",
                    },
                },
                token,
            };
              await sendANotification(message);
              console.log("sent to author successfully");
          }else{
            const message = {
              notification: {
                title: 'New match',
                body: `${userDataA.username} added you to their new match`,
              },
              data: {
                  click_action: "FLUTTER_NOTIFICATION_CLICK",
                  tab: "/Matches",
                  d:post.matchId
              },
              android: {
                  notification: {
                      sound: "default",
                      image:"",
                  },
              },
              token,
          };
            await addANotification(userData.docRef, currentUserUid, userId, post.matchId,"added you to their new match");
            await sendANotification(message);
            console.log("sent to user1 successfully");
          }
        }}
      }catch(error){
        console.error("error:",error);
      } 
      };

        const club1Data=await fetchUserData(club1Id);
        const club2Data=await fetchUserData(club2Id);
        await sendClubNotification(club1Data);
        await sendClubNotification(club2Data);
      const useruids = Array.from(followingUids);
      const registrationTokens:string[] = [];
      const usersData: {
        userId: string;
        userRef:DocumentReference;
       }[]=[];
      // Fetch FCM tokens for all following users
      const promises = useruids.map(async (followerId) => {
        const userData= await fetchUserData(followerId);
        if (userData !== undefined) {
          registrationTokens.push(userData.token);
          usersData.push({
            userId:userData.userId,
            userRef:userData.docRef,
          });
        }
      });

      await Promise.all(promises);
      // Subscribe the devices to the topic
      const topic = 'match_notifications' + currentUserUid;
      const message = {
        notification: {
          title: 'New match',
          body: `${userDataA.username} added a new match`,
        },
        topic: topic,
        data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            tab: "/Matches",
            d:post.matchId
        },
        android: {
            notification: {
                sound: "default",
                image: "",
            },
        },
    };
    const uniquetokens = Array.from(new Set(registrationTokens)).filter(Boolean);
    await sendAllNotification(uniquetokens,message,topic);
      await addAllNotifications(usersData,currentUserUid,post.matchId,"added a new match");
      return true;
    } catch (error) {
      console.error('Error sending notifications:', error);
      return false;
    }
  });
  async function sendAllNotification(tokens: string[], message:any,topic:string){
    try{
    await getMessaging.subscribeToTopic(tokens, topic);
    console.log('Successfully subscribed to topic:', topic);
  if(tokens){
    await getMessaging.send(message);
  }}catch(error){
    console.error("error:",error)
  }
    }
  async function addAllNotifications(userRefs: {
    userId: string;
    userRef:DocumentReference;
   }[], from: string, content: string, message:string) {
    const notificationsPromises = userRefs.map(async (userdata) => {
      const querySnapshot = await userdata.userRef.collection("notifications").orderBy('createdAt', 'desc').limit(1).get();
      const latestDoc = querySnapshot.docs[0];
  
      let allNotifications = [];
      let isNewDocument = true;
  
      if (!querySnapshot.empty) {
        const latestData = latestDoc.data();
        allNotifications = latestData?.notifications || [];
  
        // Check if the latest document is under the size limit
        if (allNotifications.length < 5000) {
          isNewDocument = false;
        }
      }
  
      // Generate a random notification ID
      const notifiId = generateRandomUid(28);
  
      // Create the new notification object
      const notification = {
        'NotifiId': notifiId,
        'from': from,
        'to': userdata.userId,
        'message': message,
        'content': content,
        'createdAt': admin.firestore.Timestamp.now(),
      };
  
      if (isNewDocument) {
        // If a new document is needed or the latest document doesn't exist
        await userdata.userRef.collection('notifications').add({
          notifications: [notification],
          createdAt: admin.firestore.Timestamp.now(),
          // Add other necessary fields
        });
      } else {
        // If the latest document exists and is under the size limit, update it
        await latestDoc.ref.update({
          notifications: [...allNotifications, notification],
          // Add other necessary fields
        });
      }
    });
  
    await Promise.all(notificationsPromises);
  }
 
async function addANotification(
  userRef: FirebaseFirestore.DocumentReference, 
  from: string, to: string, content: string,message:string) {
  // Get the latest document in the notifications collection
  const querySnapshot = await userRef
  .collection("notifications").orderBy('createdAt', 'desc').limit(1).get();
  const latestDoc = querySnapshot.docs[0];

  let allNotifications: any[] = [];
  let isNewDocument = true;
  if (!querySnapshot.empty) {
    const latestData = latestDoc.data();
    allNotifications = latestData?.notifications || [];

    // Check if the latest document is under the size limit
    if (allNotifications.length < 5000) {
        isNewDocument = false;
    }
}

  // Generate a random notification ID
  const notifiId = generateRandomUid(28);

  // Create the new notification object
  const notification = {
      'NotifiId': notifiId,
      'from': from,
      'to': to,
      'message': message,
      'content': content,
      'createdAt': admin.firestore.Timestamp.now(),
  };

  if (isNewDocument) {
      // If a new document is needed or the latest document doesn't exist
      await userRef.collection('notifications').add({
          notifications: [notification],
          createdAt: admin.firestore.Timestamp.now(),
          // Add other necessary fields
      });
  } else {
      // If the latest document exists and is under the size limit, update it
      await latestDoc.ref.update({
          notifications: [...allNotifications, notification],
          // Add other necessary fields
      });
  }
}

    async function sendANotification(message:any){
      try{
      await admin.messaging().send(message);
      }catch(error){
        console.error("error",error);
      }
    }
      
//events notifications
 exports.sendeventNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).firestore
 .document('Events/{eventId}')
 .onCreate(async (snap) => {
    try {
      const post = snap.data();
      const currentUserUid = post.authorId;

      // Send notification to author's followers
      const followingUids = new Set([currentUserUid]);
      //let imageurl = '';
      //let name = '';

      const collectUids = (snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
        snapshot.forEach((doc) => {
          const followingData = doc.data()[key] as { userId: string }[];
          followingData.forEach((item) => {
            if (item.userId) {
              followingUids.add(item.userId);
            }
          });
        });
      };
      const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
        snapshot.forEach((doc) => {
          const clubsTeamTable = doc.data()[key] || [];
          const clubsteam = doc.data()['clubsteam'] || [];
          if (clubsTeamTable[1]) {
            const fieldName = clubsTeamTable[1].fn;
            clubsteam.forEach((clubItem: { [key: string]: string }) => {
              if (clubItem[fieldName]) {
                followingUids.add(clubItem[fieldName]);
              }
            });
          }
        });
      };
      
      // Collecting following UIDs
      const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
      collectUids(followingSnapshot, 'following');
  
      const clubSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
      collectUids(clubSnapshot, 'clubs');
  
      const profesSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
      collectUids(profesSnapshot, 'professionals');
  
      const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("fans").get();
      collectUids(fromclubSnapshot, 'fans');
  
      const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("fans").get();
      collectUids(fromprofeSnapshot, 'fans');
  
      const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("clubsteam").get();
      collectUids1(fromclubteamSnapshot, 'clubsTeamTable');
  
      const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("trustedaccounts").get();
      collectUids(fromprofetSnapshot, 'accounts');
  
      const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("club").get();
      fromprofeclubSnapshot.forEach((doc) => {
        if (doc.id) {
          followingUids.add(doc.id);
        }
      });
      // Fetch user data for current user
    

      // Send notification to the other club
      const userData=await fetchUserData(currentUserUid);
      const token =userData.token;
      if (token) {
          const message = {
            notification: {
              title: 'New event',
              body: `You have succeded in adding a new event`,
            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                tab: "/Events",
                d:post.eventId
            },
            android: {
                notification: {
                    sound: "default",
                    image: "",
                },
            },
            token,
        };
          await sendANotification(message);
      }
      const useruids = Array.from(followingUids);
      const registrationTokens:string[] = [];
      const usersData: {
        userId: string;
        userRef:DocumentReference;
       }[]=[];
      // Fetch FCM tokens for all following users
      const promises = useruids.map(async (followerId) => {
        const userData= await fetchUserData(followerId);
        if (userData !== undefined) {
          registrationTokens.push(userData.token);
          usersData.push({
            userId:userData.userId,
            userRef:userData.docRef,
          });
        }
      });

      await Promise.all(promises);

      // Subscribe the devices to the topic
      const topic = 'event_notifications' + currentUserUid;
      const message = {
        notification: {
          title: 'New event',
          body: `${userData.username} added a new event`,
        },
        topic: topic,
        data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            tab: "/Events",
            d:post.eventId
        },
        android: {
            notification: {
                sound: "default",
                image: userData.profileImage||"",
            },
        },
    };
    const uniquetokens = Array.from(new Set(registrationTokens)).filter(Boolean);
    await sendAllNotification(uniquetokens,message,topic);
      await addAllNotifications(usersData,currentUserUid,post.eventId,"added a new event");
      return true;
    } catch (error) {
      console.error('Error sending notifications:', error);
      return false;
    }
  });
//story notifications

exports.sendStoryNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).firestore
.document('Story/{StoryId}')
.onCreate(async (snap) => {
    try {
      const post = snap.data();
      const currentUserUid = post.authorId;

      // Send notification to author's followers
      const followingUids = new Set([currentUserUid]);
      let imageurl = '';
      //let name = '';

      const collectUids = (snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
        snapshot.forEach((doc) => {
          const followingData = doc.data()[key] as { userId: string }[];
          followingData.forEach((item) => {
            if (item.userId) {
              followingUids.add(item.userId);
            }
          });
        });
      };
      const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
        snapshot.forEach((doc) => {
          const clubsTeamTable = doc.data()[key] || [];
          const clubsteam = doc.data()['clubsteam'] || [];
          if (clubsTeamTable[1]) {
            const fieldName = clubsTeamTable[1].fn;
            clubsteam.forEach((clubItem: { [key: string]: string }) => {
              if (clubItem[fieldName]) {
                followingUids.add(clubItem[fieldName]);
              }
            });
          }
        });
      };
      
      // Collecting following UIDs
      const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
      collectUids(followingSnapshot, 'following');
  
      const clubSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
      collectUids(clubSnapshot, 'clubs');
  
      const profesSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
      collectUids(profesSnapshot, 'professionals');
  
      const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("fans").get();
      collectUids(fromclubSnapshot, 'fans');
  
      const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("fans").get();
      collectUids(fromprofeSnapshot, 'fans');
  
      const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("clubsteam").get();
      collectUids1(fromclubteamSnapshot, 'clubsTeamTable');
  
      const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("trustedaccounts").get();
      collectUids(fromprofetSnapshot, 'accounts');
  
      const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("club").get();
      fromprofeclubSnapshot.forEach((doc) => {
        if (doc.id) {
          followingUids.add(doc.id);
        }
      });

      // Fetch user data for current user
        const userData=await fetchUserData(currentUserUid);
        const token=userData.token;
        if(post.story.length>0||post.story!==undefined){
          imageurl=post.story[0].url1;
        }
        if (token) {
          const message = {
            notification: {
              title: 'New story',
              body: `Uploading story complete`,
          },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                tab: "/Stories",
                d:post.StoryId
            },
            android: {
                notification: {
                    sound: "default",
                    image: imageurl,
                },
            },
            token,
        };
          await sendANotification(message);
    }; 
      const useruids = Array.from(followingUids);
      const registrationTokens:string[] = [];
      const usersData: {
        userId: string;
        userRef:DocumentReference;
       }[]=[];
      // Fetch FCM tokens for all following users
      const promises = useruids.map(async (followerId) => {
        const userData= await fetchUserData(followerId);
        if (userData !== undefined) {
          registrationTokens.push(userData.token);
          usersData.push({
            userId:userData.userId,
            userRef:userData.docRef,
          });
        }
      });

      await Promise.all(promises);

      // Subscribe the devices to the topic
      const topic = 'story_notifications' + currentUserUid;
      const message = {
        notification: {
          title: 'New story',
          body: `${userData.username} shared a story`,
      },
        topic: topic,
        data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            tab: "/Stories",
            d:post.StoryId
        },
        android: {
            notification: {
                sound: "default",
                image:  imageurl||"",
            },
        },
    };
    const uniquetokens = Array.from(new Set(registrationTokens)).filter(Boolean);
    await sendAllNotification(uniquetokens,message,topic);
      await addAllNotifications(usersData,currentUserUid,post.eventId,"shared a story",);
      return true;
    } catch (error) {
      console.error('Error sending notifications:', error);
      return false;
    }
  });


//welcome notificationSSSS
exports.sendWelcomeNotification1 = functions.firestore
  .document('Clubs/{Clubid}')
  .onCreate(async (snap) => {
    try {
      const post = snap.data();
      const token = post.fcmToken;
      const email = post.email;
      
        // Sending FCM notification
      const message = {
        notification: {
          title: 'Welcome to Fans Arena',
          body: 'Thank you for signing up as a Club, '+post.Clubname,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          tab: '/home',
          d: email
        },
        android: {
          notification: {
            sound: "default",
            image: "https://res.cloudinary.com/startup-grind/image/upload/c_fill,dpr_2.0,f_auto,g_center,q_auto:good/v1/gcs/platform-data-goog/events/DF22-Bevy-EventThumb%402x_7wlrADr.png",
          },
        },
        token,
      };

      if(token){
        await admin.messaging().send(message);
      }
        // Sending welcome email
        const sentFrom = new Sender("fansarenakenya@gmail.com", "Fans Arena");
        const recipients = [new Recipient(email, post.Clubname)];
        const emailParams = new EmailParams()
        .setFrom(sentFrom)
        .setTo(recipients)
        .setSubject('Welcome to Fans Arena')
        .setHtml(`<strong>Greetings ${post.Clubname}, thank you for signing up as a Club at Fans Arena.<strong>`)
        .setText(`Greetings ${post.Clubname}, thank you for signing up as a Club at Fans Arena.`);
      await mailersend.email.send(emailParams);
      console.log('Welcome email sent successfully');
    
      console.log('FCM notification sent successfully');
    } catch (error) {
      console.error('Error sending notifications:', error);
     
    }
  });

exports.sendWelcomeNotification2 = functions.firestore
.document('Professionals/{profeid}')
.onCreate(async (snap) => {
  try {
    const post=snap.data();
    const token=post.fcmToken;
    const email= post.email;

        //Fcm
  const message = {
    notification: {
        title: 'Welcome to Fans Arena',
        body: 'Thank you for signing up as a Professional, '+post.Stagename,
    },
    data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        tab: '/home',
        d:email,
    },
    android: {
        notification: {
            sound: "default",
            image: "https://res.cloudinary.com/startup-grind/image/upload/c_fill,dpr_2.0,f_auto,g_center,q_auto:good/v1/gcs/platform-data-goog/events/DF22-Bevy-EventThumb%402x_7wlrADr.png",
        },
    },
    token,
};
if(token){
      await admin.messaging().send(message);
    }
      
  
    const sentFrom = new Sender("fansarenakenya@gmail.com", "Fans Arena");
    const recipients = [new Recipient(email, post.Stagename)];
    const emailParams = new EmailParams()
    .setFrom(sentFrom)
    .setTo(recipients)
    .setSubject('Welcome to Fans Arena')
    .setHtml(`<strong>Greetings ${post.Stagename}, thank you for signing up as a Professional at Fans Arena.<strong>`)
    .setText(`Greetings ${post.Clubname}, thank you for signing up as a Professional at Fans Arena.`);
  await mailersend.email.send(emailParams);
  console.log('Welcome email sent successfully');

  console.log('FCM notification sent successfully');

} catch (error) {
  console.error('Error sending notifications:', error);
  
}
});

exports.sendWelcomeNotification3 = functions.firestore
.document('Fans/{Fanid}')
.onCreate(async (snap) => {
  try {
    const post=snap.data();
    const token=post.fcmToken;
    const email= post.email;

       //fcm
  const message = {
    notification: {
        title: 'Welcome to Fans Arena',
        body: 'Thank you for signing up as a Fan, '+post.username,
    },
    data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        tab: '/home',
        d:email,
    },
    android: {
        notification: {
            sound: "default",
            image:"https://res.cloudinary.com/startup-grind/image/upload/c_fill,dpr_2.0,f_auto,g_center,q_auto:good/v1/gcs/platform-data-goog/events/DF22-Bevy-EventThumb%402x_7wlrADr.png",
        },
    },
    token,
};
 if(token){
      await admin.messaging().send(message);
    }
     // Sending welcome email
     const sentFrom = new Sender("fansarenakenya@gmail.com", "Fans Arena");
     const recipients = [new Recipient(email, post.username)];
     const emailParams = new EmailParams()
     .setFrom(sentFrom)
     .setTo(recipients)
     .setSubject('Welcome to Fans Arena')
     .setHtml(`<strong>Greetings ${post.username}, thank you for signing up as a Fan at Fans Arena.<strong>`)
     .setText(`Greetings ${post.username}, thank you for signing up as a Fan at Fans Arena.`);
   await mailersend.email.send(emailParams);
   console.log('Welcome email sent successfully');
   console.log('FCM notification sent successfully');
 
} catch (error) {
  console.error('Error sending notifications:', error);
  
}
});

//send notification to show event started

exports.sendOnliveNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const matchId: string | undefined = queryParams["eventId"] as string;
    const event: string | undefined = queryParams["event"] as string;
    if (!currentUserUid || !matchId) {
   response.status(400).json({ error: "uid and eventId are required" });
        return;
    }

      // Send notification to author's followers
      const followingUids = new Set([currentUserUid]);
      let imageurl = '';
      let name = '';
      const collectUids = (snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
        snapshot.forEach((doc) => {
          const followingData = doc.data()[key] as { userId: string }[];
          followingData.forEach((item) => {
            if (item.userId) {
              followingUids.add(item.userId);
            }
          });
        });
      };
      const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
        snapshot.forEach((doc) => {
          const clubsTeamTable = doc.data()[key] || [];
          const clubsteam = doc.data()['clubsteam'] || [];
          if (clubsTeamTable[1]) {
            const fieldName = clubsTeamTable[1].fn;
            clubsteam.forEach((clubItem: { [key: string]: string }) => {
              if (clubItem[fieldName]) {
                followingUids.add(clubItem[fieldName]);
              }
            });
          }
        });
      };
      
      // Collecting following UIDs
      const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
      collectUids(followingSnapshot, 'following');
  
      const clubSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
      collectUids(clubSnapshot, 'clubs');
  
      const profesSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
      collectUids(profesSnapshot, 'professionals');
  
      const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("fans").get();
      collectUids(fromclubSnapshot, 'fans');
  
      const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("fans").get();
      collectUids(fromprofeSnapshot, 'fans');
  
      const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("clubsteam").get();
      collectUids1(fromclubteamSnapshot, 'clubsTeamTable');
  
      const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("trustedaccounts").get();
      collectUids(fromprofetSnapshot, 'accounts');
  
      const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("club").get();
      fromprofeclubSnapshot.forEach((doc) => {
        if (doc.id) {
          followingUids.add(doc.id);
        }
      });
  
    
      const useruids = Array.from(followingUids);
      const registrationTokens:string[] = [];
      const usersData: {
        userId: string;
        userRef:DocumentReference;
       }[]=[];
      // Fetch FCM tokens for all following users
      const promises = useruids.map(async (followerId) => {
        const userData= await fetchUserData(followerId);
        if (userData !== undefined) {
          registrationTokens.push(userData.token);
          usersData.push({
            userId:userData.userId,
            userRef:userData.docRef,
          });
        }
      });

      await Promise.all(promises);
    const userData=await fetchUserData(currentUserUid);
      // Subscribe the devices to the topic
      if(userData.profileImage!==undefined){
        imageurl=userData.profileImage;
      }
      if(userData.username!==undefined){
        name=userData.username;
      }
      const topic = 'event_notifications' + currentUserUid;
      const message = {
        notification: {
          title:  `${event}  has started`,
          body: `${event} from ${name} has started`,
        },
        topic: topic,
        data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            tab: "/Events",
            d:matchId
        },
        android: {
            notification: {
                sound: "default",
                image: imageurl||"",
            },
        },
    };
    const uniquetokens = Array.from(new Set(registrationTokens)).filter(Boolean);
    await sendAllNotification(uniquetokens,message,topic);
      await addAllNotifications(usersData,currentUserUid,matchId,"event has started",);
    } catch (error) {
      console.error('Error sending notifications:', error);
      response.status(500).json({ error: "Internal server error" +error});
    }
  });



//send notification to following
exports.sendfollowingNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
.onRequest(async (request, response) => {
  let username:string='';
  let imageUrl:string='';
  try{
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid1"] as string;
    const otheruid: string | undefined = queryParams["uid2"] as string;

    if (!currentUserUid || !otheruid) {
   response.status(400).json({ error: "User ID and other ID are required" });
        return;
    }

    // Fetch user data for the current user
    const currentUserSnapshot = await admin.firestore()
    .collection('Fans').doc(currentUserUid).get();
    if (!currentUserSnapshot.exists) {
      response.status(404).json({ error: "Current user not found" });
      return;
    }
    const currentUserData = currentUserSnapshot.data();
    if(currentUserData?.profileimage!==undefined){
      imageUrl=currentUserData?.profileimage;
    }
    if(currentUserData?.username!==undefined){
      username=currentUserData?.username;
    }
    // Send notification to the other user
    const otherUserSnapshot = await admin.firestore()
    .collection('Fans').doc(otheruid).get();
    if (otherUserSnapshot.exists) {
      const otherUserData = otherUserSnapshot.data();
      const token = otherUserData?.fcmToken;
           if (token) {
        const message = {
          notification: {
            title: 'New follower',
            body: `${username} is now following you`,
          },
          data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            tab: "/Follower",
          },
          android: {
            notification: {
              sound: "default",
              image: imageUrl, 
            },
          },
          token,
        };
        await sendANotification(message);
      }
    }

    response.status(200).json({ success: true, message: " successfully" });
  } catch (error) {
    console.error('Error sending notifications:', error);
    response.status(500).json({ error: "Internal server error"+error });
  }
});


exports.loginNotification = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
.onRequest(async (request, response) => {
  //let username:string='';
  //let imageUrl:string='';
  try{
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    if (!currentUserUid ) {
   response.status(400).json({ error: "User ID is required" });
        return;
    }

    // Fetch user data for the current user
   const userData= await fetchUserData(currentUserUid);
    if (userData!==undefined) { 
      const token = userData.token;
      const otherUserId = userData.userId;

      if (token) {
        const message = {
          notification: {
            title: 'Welcome Back to Fans Arena',
            body: `You Logged in as a ${userData.collectionName}, ${userData.username}`,
          },
          data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            tab: "/Login",
          },
          android: {
            notification: {
              sound: "default",
              image: '', 
            },
          },
          token,
        };
        console.log(`You Logged in as a ${userData.collectionName} ${userData.username}`);
        await sendANotification(message);
        await addANotification(userData.docRef, currentUserUid, otherUserId,"",'welcome back to Fans Arena',);
      }
    }

    response.status(200).json({ success: true, message: " successfully" });
  } catch (error) {
    console.error('Error sending notifications:', error);
    response.status(500).json({ error: "Internal server error"+error });
  }
});
function generateRandomUid(length: number): string {
  const c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  const charactersLength = c.length;
  let uid = '';
  for (let i = 0; i < length; i++) {
      uid += c.charAt(Math.floor(Math.random() * charactersLength));
  }
  return uid;
}

//send notification to club as a new fan
exports.sendnewfanNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
.onRequest(async (request, response) => {
  let username:string='';
  let imageUrl:string='';
  try{
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid1"] as string;
    const otheruid: string | undefined = queryParams["uid2"] as string;

    if (!currentUserUid || !otheruid) {
   response.status(400).json({ error: "User ID and other ID are required" });
        return;
    }

    // Fetch user data for the current user
    const currentUserSnapshot = await admin.firestore()
    .collection('Fans').doc(currentUserUid).get();
    if (!currentUserSnapshot.exists) {
      response.status(404).json({ error: "Current user not found" });
      return;
    }
    const currentUserData = currentUserSnapshot.data();
    if(currentUserData?.profileimage!==undefined){
      imageUrl=currentUserData?.profileimage;
    }
    if(currentUserData?.username!==undefined){
      username=currentUserData?.username;
    }

    // Send notification to the other user
    const otherUserSnapshot = await admin.firestore()
    .collection('Clubs').doc(otheruid).get();
    if (otherUserSnapshot.exists) {
      const otherUserData = otherUserSnapshot.data();
      const token = otherUserData?.fcmToken;
          if (token) {
        const message = {
          notification: {
            title: 'New fan',
            body: `${username} is now your fan`,
          },
          data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            tab: "/Fan",
          },
          android: {
            notification: {
              sound: "default",
              image: imageUrl, 
            },
          },
          token,
        };
        await sendANotification(message);
      }
    }

    response.status(200).json({ success: true, message: "successfully" });
  } catch (error) {
    console.error('Error sending notifications:', error);
    response.status(500).json({ error: "Internal server error"+error });
  }
});


//send notification to professional as a new fan
exports.sendnewfanPNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
.onRequest(async (request, response) => {
  let username:string='';
  let imageUrl:string='';
  try{
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid1"] as string;
    const otheruid: string | undefined = queryParams["uid2"] as string;

    if (!currentUserUid || !otheruid) {
   response.status(400).json({ error: "User ID and other ID are required" });
        return;
    }

    // Fetch user data for the current user
    const currentUserSnapshot = await admin.firestore()
    .collection('Fans').doc(currentUserUid).get();
    if (!currentUserSnapshot.exists) {
      response.status(404).json({ error: "Current user not found" });
      return;
    }
    const currentUserData = currentUserSnapshot.data();
    if(currentUserData?.profileimage!==undefined){
      imageUrl=currentUserData?.profileimage;
    }
    if(currentUserData?.username!==undefined){
      username=currentUserData?.username;
    }

    // Send notification to the other user
    const otherUserSnapshot = await admin.firestore()
    .collection('Professionals').doc(otheruid).get();
    if (otherUserSnapshot.exists) {
      const otherUserData = otherUserSnapshot.data();
      const token = otherUserData?.fcmToken;
      if (token) {
        const message = {
          notification: {
            title: 'New fan',
            body: `${username} is now your fan`,
          },
          data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            tab: "/Fan",
          },
          android: {
            notification: {
              sound: "default",
              image: imageUrl, 
            },
          },
          token,
        };
        await sendANotification(message);
      }
    }

    response.status(200).json({ success: true, message: "successfully" });
  } catch (error) {
    console.error('Error sending notifications:', error);
    response.status(500).json({ error: "Internal server error" +error});
  }
});
    
//send invite streaming notification
exports.sendinviteNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
.onRequest(async (request, response) => {
  let username:string='';
  let imageUrl:string='';
  try{
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const userIds1: string | undefined = queryParams["uids"] as string;
    const userId:string | undefined=queryParams['userId']as string;
    const  event:string | undefined=queryParams['event']as string;
    const matchId:string | undefined=queryParams['matchId'] as string;
    if (!userId || userIds1.length==0||!userId) {
       response.status(400).json({ error: "userId and userIds are required" });
        return;
    }
    const userIds=userIds1.split(',');
    const userData=await fetchUserData(userId);
        
    const useruids = Array.from(userIds);
    const registrationTokens:string[] = [];
    const usersData: {
      userId: string;
      userRef:DocumentReference;
     }[]=[];
    // Fetch FCM tokens for all following users
    const promises = useruids.map(async (followerId) => {
      const userData= await fetchUserData(followerId);
      if (userData !== undefined) {
        registrationTokens.push(userData.token);
        usersData.push({
          userId:userData.userId,
          userRef:userData.docRef,
        });
      }
    });

    await Promise.all(promises);
    if(userData.profileImage!==undefined){
      imageUrl=userData.profileImage;
    }
    if(userData.username!==undefined){
      username=userData.username;
    }
    const topic = event+'invite_notifications' +userId;
    const message = {
      notification: {
        title: 'Streaming Invitation',
        body: `${username} invited you to assist in filming their ${event}`,
      },
      topic: topic,
      data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          tab: "/Events",
          d:matchId
      },
      android: {
          notification: {
              sound: "default",
              image: imageUrl||"",
          },
      },
  };
  const uniquetokens = Array.from(new Set(registrationTokens)).filter(Boolean);
  await sendAllNotification(uniquetokens,message,topic);
    response.status(200).json({ success: true, message: "successfully" });
  
  } catch (error) {
    console.error('Error sending notifications:', error);
    response.status(500).json({ error: "Internal server error"+error });
  }
});



// sendleague notificatins
exports.sendleaguematchcreatedNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const leagueId: string | undefined = queryParams["leagueId"] as string;
    const matchId: string | undefined = queryParams["matchId"] as string;
    const club1: string | undefined = queryParams["club1"] as string;
    const club2: string | undefined = queryParams["club2"] as string;

    if (!leagueId || !matchId||!club1||!club2) {
   response.status(400).json({error:
     "leagueId,matchId,club1,club2 are required"});
        return;
    }

      // Send notification to author's followers
      const followingUids: Set<string> = new Set();
    //const allclubs: Set<string> = new Set([club1, club2]);
    
      
  
      let imageurl = '';
      //let name = '';

      // Helper function to collect UIDs
      const collectUids = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
        snapshot.forEach((doc) => {
          const followingData = doc.data()[key] || [];
          followingData.forEach((item: { userId: any; }) => {
            if (item.userId) {
              followingUids.add(item.userId);
            }
          });
        });
      };
      const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
        snapshot.forEach((doc) => {
          const clubsTeamTable = doc.data()[key] || [];
          const clubsteam = doc.data()['clubsteam'] || [];
          if (clubsTeamTable[1]) {
            const fieldName = clubsTeamTable[1].fn;
            clubsteam.forEach((clubItem: { [key: string]: string }) => {
              if (clubItem[fieldName]) {
                followingUids.add(clubItem[fieldName]);
              }
            });
          }
        });
      };

      // Collecting following UIDs
      const LeaguesSnapshot = await admin.firestore()
      .collection("Leagues").doc(leagueId).collection('year').get();
      LeaguesSnapshot.forEach(async (doc) => {
       const allclubsSnapshot= await admin.firestore()
        .collection("Leagues").doc(leagueId).collection('year')
        .doc(doc.id).collection('clubs').get();
        allclubsSnapshot.forEach((doc)=>{
          const followingData = doc.data().clubs as { clubId: string }[];
          followingData.forEach((club) => {
            if(club.clubId!=club1||club.clubId!=club2){
           followingUids.add(club.clubId);
            }
          });
        });
    });
    const subsQuery = await admin.firestore()
    .collection("Leagues").doc(leagueId)
    .collection("subscribers").get();
  subsQuery.forEach((doc) => {
    const followingData = doc.data().subscribers as { userId: string }[];
    followingData.forEach((sub) => {
   followingUids.add(sub.userId);
    });
  });
  const getclubsF = async (club:string) => {
      const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(club).collection("fans").get();
      collectUids(fromclubSnapshot, 'fans');
      const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(club).collection("fans").get();
      collectUids(fromprofeSnapshot, 'fans');
      const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(club).collection("clubsteam").get();
      collectUids1(fromclubteamSnapshot, 'clubsTeamTable');
      const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(club).collection("trustedaccounts").get();
      collectUids(fromprofetSnapshot, 'accounts');
      const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(club).collection("club").get();
      fromprofeclubSnapshot.forEach((doc) => {
        if (doc.id) {
          followingUids.add(doc.id);
        }
      });
    }

      // Fetch user data for current user
      const sendClubNotification = async (userData:any) => {
        if (userData !== undefined) {
          const token =userData.token;
          if (token!==undefined) {
            const message = {
              notification: {
                title: 'New match',
                body: `${userData3.username} has created a match for you `,
              },
              data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                tab: "/LMATCH",
                d:matchId
              },
              android: {
                notification: {
                  sound: "default",
                  image: userData3.profileImage, 
                },
              },
              token,
            };
              await sendANotification(message);
              await addANotification(userData.docRef,leagueId,userData.userId,matchId,'league has created a match for you',);
        }} 
      };

      const userData1=await fetchUserData(club1);
      const userData2=await fetchUserData(club2);
      const userData3=await fetchUserData(leagueId);
        await getclubsF(club1);
        await getclubsF(club2);
        await sendClubNotification(userData1);
        await sendClubNotification(userData3);
        await sendClubNotification(club1);
        await sendClubNotification(club2);
      
  
      const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);
      const useruids = Array.from(uniqueUids);
      const registrationTokens:string[] = [];
      const usersData: {
        userId: string;
        userRef:DocumentReference;
       }[]=[];
      // Fetch FCM tokens for all following users

      const promises = useruids.map(async (followerId) => {
        const userData= await fetchUserData(followerId);
        if (userData !== undefined) {
          registrationTokens.push(userData.token);
          usersData.push({
            userId:userData.userId,
            userRef:userData.docRef,
          });
        }
      });

      await Promise.all(promises);
      if(userData3.profileImage!==undefined){
      imageurl = userData3.profileImage;
          //name = userData1?.Clubname;
      }
      // Subscribe the devices to the topic
      const topic = 'leaguematch_notifications' + leagueId;
      const message = {
        notification: {
          title: 'New match',
          body: `${userData3.username} has created a match, ${userData1.username} vs ${userData2.username} `,
        },
        topic: topic,
        data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            tab: "/LMatch",
            d:matchId
        },
        android: {
            notification: {
                sound: "default",
                image:  imageurl,
            },
        },
    };
    const uniquetokens = Array.from(new Set(registrationTokens)).filter(Boolean);
    await sendAllNotification(uniquetokens,message,topic);
      await addAllNotifications(usersData,leagueId,matchId, 'league has created a match',);
    } catch (error) {
      console.error('Error sending notifications:', error);
      response.status(500).json({ error: "Internal server error" +error});
    }
  });

//liking a post online mode... use queue
//commenting a post oneline mode... use queue
//commenting a post offline mode
//liking a post offline mode
//chatting online mode... use queue
//chatiing offline mode
//posts you have interacted with

exports.getpostsinteractedwith = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams = request.query;
    const currentUserUid = queryParams["uid"];

    if (!currentUserUid) {
      response.status(400).json({ error: "User ID is required" });
      return;
    }

    const matchIds = new Set();
    const allLeaguesSnapshot = await admin.firestore().collection("posts").get();

    for (const leagueDoc of allLeaguesSnapshot.docs) {
      const matchId = leagueDoc.id;

      const allCommentsSnapshot = await admin.firestore()
        .collection("posts").doc(matchId)
        .collection("comments").get();
      if (!allCommentsSnapshot.empty) {
        allCommentsSnapshot.docs.forEach((doc) => {
          const followingData = doc.data().comments || [];
          followingData.forEach((comment: { userId: string | ParsedQs | string[] | ParsedQs[]; }) => {
            if (currentUserUid === comment.userId) {
              matchIds.add(matchId);
            }
          });
        });
      }

      const allLikesSnapshot = await admin.firestore()
        .collection("posts").doc(matchId)
        .collection("likes").get();
      if (!allLikesSnapshot.empty) {
        allLikesSnapshot.docs.forEach((doc) => {
          const followingData = doc.data().likes || [];
          followingData.forEach((like: { userId: string | ParsedQs | string[] | ParsedQs[]; }) => {
            if (currentUserUid === like.userId) {
              matchIds.add(matchId);
            }
          });
        });
      }

      const allRepliesSnapshot = await admin.firestore()
        .collection("posts").doc(matchId)
        .collection("replies").get();
      if (!allRepliesSnapshot.empty) {
        allRepliesSnapshot.docs.forEach((doc) => {
          const followingData = doc.data().replies || [];
          followingData.forEach((reply: { userId: string | string[] | ParsedQs | ParsedQs[]; }) => {
            if (currentUserUid === reply.userId) {
              matchIds.add(matchId);
            }
          });
        });
      }
    }

    const matchIdsArray = Array.from(matchIds);
    const chunkSize = 30;
    const matchChunks = [];
    for (let i = 0; i < matchIdsArray.length; i += chunkSize) {
      matchChunks.push(matchIdsArray.slice(i, i + chunkSize));
    }

    const postsPromises = matchChunks.map(async (chunk) => {
      const postsQuery = await admin.firestore().collection("posts")
        .where("postId", "in", chunk)
        .orderBy("createdAt", "desc")
        .limit(4)
        .get();

      return postsQuery.docs.map((doc) => ({
        postId: doc.id,
        createdAt: doc.data().createdAt,
        authorId: doc.data().authorId,
        location: doc.data().location,
        genre: doc.data().genre,
        captionUrl: doc.data().captionUrl,
        commenting: doc.data().commenting,
        likes: doc.data().likes,
      }));
    });

    const postsArrays = await Promise.all(postsPromises);
    const posts1 = postsArrays.flat();

    const posts = await Promise.all(posts1.map(async (post) => {
      const userData = await fetchUserData(post.authorId);
      const captionUrl=await getImageAspectRatios(post.captionUrl)
      return {
        ...post,
        author:userData,
        captionUrl:captionUrl,
      };
    }));

    response.json({ posts });
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({ error: "Failed to get posts" + error });
  }
});
//fanstv you have interacted with
exports.getFansTvinteractedwith = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams = request.query;
    const currentUserUid = queryParams["uid"];

    if (!currentUserUid) {
      response.status(400).json({ error: "User ID is required" });
      return;
    }

    const matchIds = new Set();
    const allLeaguesSnapshot = await admin.firestore().collection("FansTv").get();

    for (const leagueDoc of allLeaguesSnapshot.docs) {
      const matchId = leagueDoc.id;

      const allCommentsSnapshot = await admin.firestore()
        .collection("FansTv").doc(matchId)
        .collection("comments").get();
      if (!allCommentsSnapshot.empty) {
        allCommentsSnapshot.docs.forEach((doc) => {
          const followingData = doc.data().comments || [];
          followingData.forEach((comment: { userId: string | ParsedQs | string[] | ParsedQs[]; }) => {
            if (currentUserUid === comment.userId) {
              matchIds.add(matchId);
            }
          });
        });
      }

      const allLikesSnapshot = await admin.firestore()
        .collection("FansTv").doc(matchId)
        .collection("likes").get();
      if (!allLikesSnapshot.empty) {
        allLikesSnapshot.docs.forEach((doc) => {
          const followingData = doc.data().likes || [];
          followingData.forEach((like: { userId: string | ParsedQs | string[] | ParsedQs[]; }) => {
            if (currentUserUid === like.userId) {
              matchIds.add(matchId);
            }
          });
        });
      }

      const allViewsSnapshot = await admin.firestore()
        .collection("FansTv").doc(matchId)
        .collection("views").get();
      if (!allViewsSnapshot.empty) {
        allViewsSnapshot.docs.forEach((doc) => {
          const followingData = doc.data().views || [];
          followingData.forEach((view: { userId: string | ParsedQs | string[] | ParsedQs[]; }) => {
            if (currentUserUid === view.userId) {
              matchIds.add(matchId);
            }
          });
        });
      }

      const allRepliesSnapshot = await admin.firestore()
        .collection("FansTv").doc(matchId)
        .collection("replies").get();
      if (!allRepliesSnapshot.empty) {
        allRepliesSnapshot.docs.forEach((doc) => {
          const followingData = doc.data().replies || [];
          followingData.forEach((reply: { userId: string | ParsedQs | string[] | ParsedQs[]; }) => {
            if (currentUserUid === reply.userId) {
              matchIds.add(matchId);
            }
          });
        });
      }
    }

    const matchIdsArray = Array.from(matchIds);
    const chunkSize = 30;
    const matchChunks = [];
    for (let i = 0; i < matchIdsArray.length; i += chunkSize) {
      matchChunks.push(matchIdsArray.slice(i, i + chunkSize));
    }

    const postsPromises = matchChunks.map(async (chunk) => {
      const postsQuery = await admin.firestore().collection("FansTv")
        .where("postId", "in", chunk)
        .orderBy("createdAt", "desc")
        .limit(4)
        .get();

      return postsQuery.docs.map((doc) => ({
        postId: doc.id,
        createdAt: doc.data().createdAt,
        authorId: doc.data().authorId,
        location: doc.data().location,
        caption: doc.data().caption,
        genre: doc.data().genre,
        url: doc.data().url,
        thumbnail:doc.data().thumbnail,
        commenting: doc.data().commenting,
        likes: doc.data().likes,
      }));
    });

    const postsArrays = await Promise.all(postsPromises);
    const posts1 = postsArrays.flat();

    const posts = await Promise.all(posts1.map(async (post) => {
      const userData = await fetchUserData(post.authorId);

      return {
        ...post,
        author:userData
      };
    }));

    response.json({ posts });
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({ error: "Failed to get posts" + error });
  }
});
//shared their lineup
exports.sendmatchlineupNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const matchId: string | undefined = queryParams["matchId"] as string;

    if (!currentUserUid || !matchId) {
response.status(400).json({ error: "uid and matchId are required" });
        return;
    }

  
    // Send notification to author's followers
    const followingUids: Set<string> = new Set([currentUserUid]);
  //  let imageurl:string='';
    //let name:string='';

      // Helper function to collect UIDs
      const collectUids = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
        snapshot.forEach((doc) => {
          const followingData = doc.data()[key] || [];
          followingData.forEach((item: { userId: any; }) => {
            if (item.userId) {
              followingUids.add(item.userId);
            }
          });
        });
      };
      const collectUids1 = (snapshot: any[] | admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {    
        snapshot.forEach((doc) => {
          const clubsTeamTable = doc.data()[key] || [];
          const clubsteam = doc.data()['clubsteam'] || [];
          if (clubsTeamTable[1]) {
            const fieldName = clubsTeamTable[1].fn;
            clubsteam.forEach((clubItem: { [key: string]: string }) => {
              if (clubItem[fieldName]) {
                followingUids.add(clubItem[fieldName]);
              }
            });
          }
        });
      };

      // Collecting following UIDs
      const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
      collectUids(followingSnapshot, 'following');

      const clubSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
      collectUids(clubSnapshot, 'clubs');

      const profesSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
      collectUids(profesSnapshot, 'professionals');

      const fromclubSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("fans").get();
      collectUids(fromclubSnapshot, 'fans');

      const fromprofeSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("fans").get();
      collectUids(fromprofeSnapshot, 'fans');

      const fromclubteamSnapshot = await admin.firestore().collection("Clubs").doc(currentUserUid).collection("clubsteam").get();
      collectUids1(fromclubteamSnapshot, 'clubsTeamTable');

      const fromprofetSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("trustedaccounts").get();
      collectUids(fromprofetSnapshot, 'accounts');

      const fromprofeclubSnapshot = await admin.firestore().collection("Professionals").doc(currentUserUid).collection("club").get();
      fromprofeclubSnapshot.forEach((doc) => {
        if (doc.id) {
          followingUids.add(doc.id);
        }
      });

      // Fetch user data for current user
  
    
      const useruids = Array.from(followingUids);
      const registrationTokens:string[] = [];
      const usersData: {
        userId: string;
        userRef:DocumentReference;
       }[]=[];
      // Fetch FCM tokens for all following users
      const promises = useruids.map(async (followerId) => {
        const userData= await fetchUserData(followerId);
        if (userData !== undefined) {
          registrationTokens.push(userData.token);
          usersData.push({
            userId:userData.userId,
            userRef:userData.docRef,
          });
        }
      });

      await Promise.all(promises);
      const userData3=await fetchUserData(currentUserUid);
      const token = userData3.token;
       if(token){
        const message = {
          notification: {
            title: 'New Line Up',
            body: `You have succeded in uploading Line Up`,
          },
          data: {
              click_action: "FLUTTER_NOTIFICATION_CLICK",
              tab: "/Matches",
              d:matchId
          },
          android: {
              notification: {
                  sound: "default",
                  image: "",
              },
          },
          token,
      };
        await sendANotification(message);
       }
      // Subscribe the devices to the topic
      const topic = 'match_notifications' + currentUserUid;
      const message = {
        notification: {
          title: 'Match Lineup',
          body: `${userData3.username} has shared their lineup `,
        },
        topic: topic,
        data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            tab: "/Matches",
            d:matchId
        },
        android: {
            notification: {
                sound: "default",
                image:  '',
            },
        },
    };
      const uniquetokens = Array.from(new Set(registrationTokens)).filter(Boolean);
      await sendAllNotification(uniquetokens,message,topic);
      await addAllNotifications(usersData,currentUserUid,matchId,"shared their line_up",);
    } catch (error) {
      console.error('Error sending notifications:', error);
      response.status(500).json({ error: "Internal server error" +error});
    }
  });

//shared their lineup
exports.sendcommentNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const from: string | undefined = queryParams["from"] as string;
    const to: string | undefined = queryParams["to"] as string;
    const comment: string | undefined = queryParams["comment"] as string;
    const commentId: string | undefined = queryParams["commentId"] as string;
    const postId:string | undefined = queryParams["postId"] as string;
    const event:string | undefined = queryParams["event"] as string;
     
    let username:string='';

    if (!comment || !commentId || !to || !from) {
response.status(400).json({ 
  error: "from, to,comment and commentId are required" });
        return;
    }
    const userData=await fetchUserData(from);
    if(userData.username!==undefined){
    username=userData.username;
    }
    const userData1=await fetchUserData(to); 
    const token=userData1.token;
    const message = {
      notification: {
        title: 'New Comment',
        body: `${username} has commented on your ${event} `,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        tab: "/Comment",
        d:commentId,
      },
      android: {
        notification: {
          sound: "default",
          image:'', 
        },
      },
      token
    };
    await addANotification(userData1.docRef,from,to,postId,`has commented on your ${event}`);
    await sendANotification(message);
  
    // Send notification to author's followers

    response.json({});
  } catch (error) {
    console.error('Error sending notifications:', error);
    response.status(500).json({ error: "Internal server error" });
  }
});

exports.sendreplyNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const from: string | undefined = queryParams["from"] as string;
    const to: string | undefined = queryParams["to"] as string;
    const comment: string | undefined = queryParams["reply"] as string;
    const commentId: string | undefined = queryParams["replyId"] as string;
    const postId:string | undefined = queryParams["postId"] as string;
    const event:string | undefined = queryParams["event"] as string;
     
    let username:string='';

    if (!comment || !commentId || !to || !from) {
response.status(400).json({ 
  error: "from, to,comment and commentId are required" });
        return;
    }
    const userData=await fetchUserData(from);
    if(userData.username!==undefined){
    username=userData.username;
    }
    const userData1=await fetchUserData(to); 
    const token=userData1.token;
    const message = {
      notification: {
        title: 'New Comment',
        body: `${username} has replied to your comment on a, ${event}`,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        tab: "/Comment",
        d:commentId,
      },
      android: {
        notification: {
          sound: "default",
          image:'', 
        },
      },
      token
    };
    await addANotification(userData1.docRef,from,to,postId,`${username} has replied to your comment on a, ${event}`);
    await sendANotification(message);
  
    // Send notification to author's followers

    response.json({});
  } catch (error) {
    console.error('Error sending notifications:', error);
    response.status(500).json({ error: "Internal server error" });
  }
});
exports.sendlikedNotifications = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const from: string | undefined = queryParams["from"] as string;
    const to: string | undefined = queryParams["to"] as string;
    const postId:string | undefined = queryParams["postId"] as string;
    const event:string | undefined = queryParams["event"] as string;
     
    let username:string='';

    if (!to || !from) {
response.status(400).json({ 
  error: "from, to,comment and commentId are required" });
        return;
    }
    const userData=await fetchUserData(from);
    if(userData.username!==undefined){
    username=userData.username;
    }
    const userData1=await fetchUserData(to); 
    const token=userData1.token;
    const message = {
      notification: {
        title: 'New like',
        body: `${username} liked your ${event}`,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        tab: "/post",
        d:postId,
      },
      android: {
        notification: {
          sound: "default",
          image:'', 
        },
      },
      token
    };
    await sendANotification(message);
  
    // Send notification to author's followers

    response.json({});
  } catch (error) {
    console.error('Error sending notifications:', error);
    response.status(500).json({ error: "Internal server error" });
  }
});

exports.sendInvitationNotification = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https
.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const from: string | undefined = queryParams["from"] as string;
    const to: string | undefined = queryParams["to"] as string;
    const m: string | undefined = queryParams["message"] as string;
    if ( !to || !from) {
     response.status(400).json({ 
      error: "from, to,comment and commentId are required" });
        return;
    }
    const userData1=await fetchUserData(to); 
    const token=userData1.token;
    const message = {
      notification: {
        title: 'Ivitation',
        body: m,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        tab: "/Inivite",
        d:'',
      },
      android: {
        notification: {
          sound: "default",
          image:'', 
        },
      },
      token
    };
    await sendANotification(message);
    // Send notification to author's followers
    response.json({});
  } catch (error) {
    console.error('Error sending notifications:', error);
    response.status(500).json({ error: "Internal server error" });
  }
});
//matches you have watched

exports.getmatcheswatched = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams = request.query;
    const currentUserUid = queryParams["uid"];

    if (!currentUserUid) {
      response.status(400).json({ error: "User ID is required" });
      return;
    }

    const matchIds = new Set();
    const allLeaguesSnapshot = await admin.firestore().collection("Matches").get();

    for (const leagueDoc of allLeaguesSnapshot.docs) {
      const matchId = leagueDoc.id;

      const allcommentsSnapshot = await admin.firestore()
        .collection("Matches").doc(matchId)
        .collection("comments").get();
      if (!allcommentsSnapshot.empty) {
        allcommentsSnapshot.docs.forEach((doc) => {
          const followingData = doc.data().comments || [];
          followingData.forEach((comment: { userId: string | ParsedQs | string[] | ParsedQs[]; }) => {
            if (currentUserUid === comment.userId) {
              matchIds.add(matchId);
            }
          });
        });
      }

      const allLikesSnapshot = await admin.firestore()
        .collection("Matches").doc(matchId)
        .collection("likes").get();
      if (!allLikesSnapshot.empty) {
        allLikesSnapshot.docs.forEach((doc) => {
          const followingData = doc.data().likes || [];
          followingData.forEach((like: { userId: string | ParsedQs | string[] | ParsedQs[]; }) => {
            if (currentUserUid === like.userId) {
              matchIds.add(matchId);
            }
          });
        });
      }

      const allviewsSnapshot = await admin.firestore()
        .collection("Matches").doc(matchId)
        .collection("views").get();
      if (!allviewsSnapshot.empty) {
        allviewsSnapshot.docs.forEach((doc) => {
          const followingData = doc.data().views || [];
          followingData.forEach((view: { userId: string | ParsedQs | string[] | ParsedQs[]; }) => {
            if (currentUserUid === view.userId) {
              matchIds.add(matchId);
            }
          });
        });
      }
    }

    const matchIdsArray = Array.from(matchIds);
    const chunkSize = 30;
    const matchChunks = [];
    for (let i = 0; i < matchIdsArray.length; i += chunkSize) {
      matchChunks.push(matchIdsArray.slice(i, i + chunkSize));
    }

    const matchesPromises = matchChunks.map(async (chunk) => {
      const postsQuery = await admin.firestore().collection("Matches")
        .where("matchId", "in", chunk)
        .orderBy("createdAt", "desc")
        .limit(4)
        .get();

      return postsQuery.docs.map((doc) => ({
        matchId: doc.id,
        createdAt: doc.data().createdAt,
        location: doc.data().location,
        matchUrl: doc.data().matchUrl,
        activeuser: doc.data().activeuser,
        club1Id: doc.data().club1Id,
        club2Id: doc.data().club2Id,
        duration: doc.data().duration,
        leagueId: doc.data().leagueId,
        leaguematchId: doc.data().leaguematchId,
        match1Id: doc.data().match1Id,
        message: doc.data().message,
        pausetime: doc.data().pausetime,
        resumetime: doc.data().resumetime,
        scheduledDate: doc.data().scheduledDate,
        score1: doc.data().score1,
        score2: doc.data().score2,
        starttime: doc.data().starttime,
        state1: doc.data().state1,
        state2: doc.data().state2,
        stoptime: doc.data().stoptime,
        time: doc.data().time,
        title: doc.data().title,
      }));
    });

    const matchesArrays = await Promise.all(matchesPromises);
    const matches1 = matchesArrays.flat();

    const matches = await Promise.all(matches1.map(async (post) => {
      const userData1 = await fetchUserData(post.club1Id);
      const userData2 = await fetchUserData(post.club2Id);
      const userData3 = await fetchUserData(post.leagueId);

      return {
        ...post,
        club1: userData1,
        club2: userData2,
        league: userData3,
      };
    }));

    response.json({ matches });
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({ error: "Failed to get posts" });
  }
});

//events you have watched
exports.geteventswatched = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams = request.query;
    const currentUserUid = queryParams["uid"];

    if (!currentUserUid) {
      response.status(400).json({ error: "User ID is required" });
      return;
    }

    const eventIds = new Set();
    const allLeaguesSnapshot = await admin.firestore().collection("Events").get();

    for (const leagueDoc of allLeaguesSnapshot.docs) {
      const eventId = leagueDoc.id;

      const allCommentsSnapshot = await admin.firestore()
        .collection("Events").doc(eventId)
        .collection("comments").get();
      if (!allCommentsSnapshot.empty) {
        allCommentsSnapshot.docs.forEach((doc) => {
          const followingData = doc.data().comments || [];
          followingData.forEach((comment: { userId: string | ParsedQs | string[] | ParsedQs[]; }) => {
            if (currentUserUid === comment.userId) {
              eventIds.add(eventId);
            }
          });
        });
      }

      const allLikesSnapshot = await admin.firestore()
        .collection("Events").doc(eventId)
        .collection("likes").get();
      if (!allLikesSnapshot.empty) {
        allLikesSnapshot.docs.forEach((doc) => {
          const followingData = doc.data().likes || [];
          followingData.forEach((like: { userId: string | ParsedQs | string[] | ParsedQs[]; }) => {
            if (currentUserUid === like.userId) {
              eventIds.add(eventId);
            }
          });
        });
      }

      const allViewsSnapshot = await admin.firestore()
        .collection("Events").doc(eventId)
        .collection("views").get();
      if (!allViewsSnapshot.empty) {
        allViewsSnapshot.docs.forEach((doc) => {
          const followingData = doc.data().views || [];
          followingData.forEach((view: { userId: string | ParsedQs | string[] | ParsedQs[]; }) => {
            if (currentUserUid === view.userId) {
              eventIds.add(eventId);
            }
          });
        });
      }
    }

    const eventIdsArray = Array.from(eventIds);
    const chunkSize = 30;
    const eventChunks = [];
    for (let i = 0; i < eventIdsArray.length; i += chunkSize) {
      eventChunks.push(eventIdsArray.slice(i, i + chunkSize));
    }

    const eventsPromises = eventChunks.map(async (chunk) => {
      const postsQuery = await admin.firestore().collection("Events")
        .where("eventId", "in", chunk)
        .orderBy("createdAt", "desc")
        .limit(4)
        .get();

      return postsQuery.docs.map((doc) => ({
        eventId: doc.id,
        createdAt: doc.data().createdAt,
        location: doc.data().location,
        authorId: doc.data().authorId,
        eventUrl: doc.data().eventUrl,
        activeuser: doc.data().activeuser,
        duration: doc.data().duration,
        message: doc.data().message,
        pausetime: doc.data().pausetime,
        resumetime: doc.data().resumetime,
        scheduledDate: doc.data().scheduledDate,
        starttime: doc.data().starttime,
        state1: doc.data().state1,
        state2: doc.data().state2,
        stoptime: doc.data().stoptime,
        time: doc.data().time,
        title: doc.data().title,
      }));
    });

    const eventsArrays = await Promise.all(eventsPromises);
    const events1 = eventsArrays.flat();

    const events = await Promise.all(events1.map(async (post) => {
      const userData1 = await fetchUserData(post.authorId);

      return {
        ...post,
       author: userData1,
      };
    }));

    response.json({events});
  } catch (error) {
    console.error("Error getting events:", error);
    response.status(500).json({ error: "Failed to get events" });
  }
});
//Todays matches
exports.getTodaysmatches=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const date: string | undefined = queryParams["date"] as string;

    if (!currentUserUid || !date) {
response.status(400).json({ error: "uid and date are required" });
        return;
    }

    const followingUids: string[] = [currentUserUid];
    const clubSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("clubs").get();

    clubSnapshot.forEach((doc) => {
      const followingData = doc.data().clubs as { userId: string }[];
      followingData.forEach((clubs) => {
        followingUids.push(clubs.userId);
      });
    });
    const profesSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("professionals").get();

    profesSnapshot.forEach((doc) => {
      const followingData = doc.data().professionals as { userId: string }[];
      followingData.forEach((professionals) => {
        followingUids.push(professionals.userId);
      });
    });
    const t= new Date(date);
    const d1= new Date(t.getFullYear(),t.getMonth(),t.getDate()-1)
    const d2= new Date(t.getFullYear(),t.getMonth(),t.getDate()-1)
   d1.setHours(0, 0, 0, 0);
   d2.setHours(23, 59, 59, 999);
   //const today= admin.firestore.Timestamp.fromDate(t); 
   const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);

   const chunkArray = (array: string[], size: number) => {
     const result = [];
     for (let i = 0; i < array.length; i += size) {
       result.push(array.slice(i, i + size));
     }
     return result;
   };

   const uidChunks = chunkArray(uniqueUids, 30);
   const postsPromises = uidChunks.map(async (uids) => {
    const postsQuery = await admin.firestore().collection("Matches")
        .where("authorId", "in", uids)
         .where('scheduledDate','>=', d1)
         .where('scheduledDate',"<=",d2)
        .orderBy("createdAt", "desc")
        .get();
    

        return postsQuery.docs.map((doc) => ({
          matchId: doc.id,
          createdAt: doc.data().createdAt, 
          authorId: doc.data().authorId,
          location: doc.data().location,
          matchUrl: doc.data().matchUrl,
          activeuser: doc.data().activeuser,
          club1Id: doc.data().club1Id,
          club2Id: doc.data().club2Id,
          duration: doc.data().duration,
          leagueId: doc.data().leagueId,
          leaguematchId: doc.data().leaguematchId,
          match1Id: doc.data().match1Id,
          message: doc.data().message,
          pausetime: doc.data().pausetime,
          resumetime: doc.data().resumetime,
          scheduledDate: doc.data().scheduledDate, 
          score1: doc.data().score1,
          score2: doc.data().score2,
          starttime: doc.data().starttime,
          state1: doc.data().state1,
          state2: doc.data().state2,
          stoptime: doc.data().stoptime,
          time: doc.data().time,
          title: doc.data().title,
      }))});

    const postsArray = await Promise.all(postsPromises);
    const posts = ([] as any[]).concat(...postsArray);

    const matches = await Promise.all(posts.map(async (post) => {
      const userData1 = await fetchUserData(post.club1Id);
      const userData2= await  fetchUserData(post.club2Id);
      const userData3= await  fetchUserData(post.leagueId);
      // Merge user data into the post object
      return {
          ...post,
          club1: userData1,
          club2: userData2,
          league: userData3,
          
      };
    }));
    response.json({matches});
  } catch (error) {
    console.error("Error getting matches:", error);
    response.status(500).json({error: "Failed to get matches"+error});
  }
});
//todays events
exports.getTodaysevents=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const date: string | undefined = queryParams["date"] as string;

    if (!currentUserUid || !date) {
response.status(400).json({ error: "uid and date are required" });
        return;
    }

    const followingUids: string[] = [currentUserUid];
    const clubSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("clubs").get();
    clubSnapshot.forEach((doc) => {
      const followingData = doc.data().clubs as { userId: string }[];
      followingData.forEach((clubs) => {
        followingUids.push(clubs.userId);
      });
    });

    const profesSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("professionals").get();
    profesSnapshot.forEach((doc) => {
      const followingData = doc.data().professionals as { userId: string }[];
      followingData.forEach((professionals) => {
        followingUids.push(professionals.userId);
      });
    });

    const t= new Date(date);
    const d1= new Date(t.getFullYear(),t.getMonth(),t.getDate()-1)
    const d2= new Date(t.getFullYear(),t.getMonth(),t.getDate()-1)
   d1.setHours(0, 0, 0, 0);
   d2.setHours(23, 59, 59, 999);
   //const today= admin.firestore.Timestamp.fromDate(t); 
    const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);

   const chunkArray = (array: string[], size: number) => {
     const result = [];
     for (let i = 0; i < array.length; i += size) {
       result.push(array.slice(i, i + size));
     }
     return result;
   };

   const uidChunks = chunkArray(uniqueUids, 30);
   const postsPromises = uidChunks.map(async (uids) => {
    const postsQuery = await admin.firestore().collection("Events")
    .where("authorId", "in", uids)
    .where('scheduledDate','>=', d1)
    .where('scheduledDate',"<=",d2)
    .orderBy("createdAt", "desc")
    .get();
    

        return postsQuery.docs.map((doc) => ({
          eventId: doc.id,
          createdAt: doc.data().createdAt, 
          location: doc.data().location,
          authorId: doc.data().authorId,
          eventUrl: doc.data().eventUrl,
          activeuser: doc.data().activeuser,
          duration: doc.data().duration,
          message: doc.data().message,
          pausetime: doc.data().pausetime,
          resumetime: doc.data().resumetime,
          scheduledDate: doc.data().scheduledDate, 
          starttime: doc.data().starttime,
          state1: doc.data().state1,
          state2: doc.data().state2,
          stoptime: doc.data().stoptime,
          time: doc.data().time,
          title: doc.data().title,
      }))});

    const postsArray = await Promise.all(postsPromises);
    const posts = ([] as any[]).concat(...postsArray);

    const events = await Promise.all(posts.map(async (post) => {
      const userData1 = await fetchUserData(post.authorId);
        // Merge user data into the post object
        return {
            ...post,
            author:userData1,
            
        };
    }));
      response.json({events});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});

//This week matches
exports.getweeksmatches=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const date: string | undefined = queryParams["date"] as string;
    if (!date) {
       response.status(400).json({ error: "uid and date are required" });
        return;
    }
    const followingUids: string[] = [currentUserUid];             
    const t = new Date(date);
    // Calculate start of the week (Sunday)
    const startOfWeek = new Date(t);
    startOfWeek.setDate(t.getDate() - t.getDay()-1);
    startOfWeek.setHours(0, 0, 0, 0);
    // Calculate end of the week (Saturday)
    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(startOfWeek.getDate() + 6);
    endOfWeek.setHours(23, 59, 59, 999);

   //const today= admin.firestore.Timestamp.fromDate(t); 

      const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);

      const chunkArray = (array: string[], size: number) => {
        const result = [];
        for (let i = 0; i < array.length; i += size) {
          result.push(array.slice(i, i + size));
        }
        return result;
      };
   
      const uidChunks = chunkArray(uniqueUids, 30);
      const postsPromises = uidChunks.map(async (uids) => {
       const postsQuery = await admin.firestore().collection("Matches")
           .where("authorId", "in", uids)
           .where('scheduledDate','>=', startOfWeek)
           .where('scheduledDate',"<=",endOfWeek)
          .orderBy("createdAt", "desc")
          .get();
   
           return postsQuery.docs.map((doc) => ({
             matchId: doc.id,
             createdAt: doc.data().createdAt, 
             authorId: doc.data().authorId,
             location: doc.data().location,
             matchUrl: doc.data().matchUrl,
             activeuser: doc.data().activeuser,
             club1Id: doc.data().club1Id,
             club2Id: doc.data().club2Id,
             duration: doc.data().duration,
             leagueId: doc.data().leagueId,
             leaguematchId: doc.data().leaguematchId,
             match1Id: doc.data().match1Id,
             message: doc.data().message,
             pausetime: doc.data().pausetime,
             resumetime: doc.data().resumetime,
             scheduledDate: doc.data().scheduledDate, 
             score1: doc.data().score1,
             score2: doc.data().score2,
             starttime: doc.data().starttime,
             state1: doc.data().state1,
             state2: doc.data().state2,
             stoptime: doc.data().stoptime,
             time: doc.data().time,
             title: doc.data().title,
         }))});
   
       const postsArray = await Promise.all(postsPromises);
       const posts = ([] as any[]).concat(...postsArray);
   
       const matches = await Promise.all(posts.map(async (post) => {
         const userData1 = await fetchUserData(post.club1Id);
         const userData2= await  fetchUserData(post.club2Id);
         const userData3= await  fetchUserData(post.leagueId);
         // Merge user data into the post object
         return {
             ...post,
         club1: userData1,
        club2: userData2,
        league: userData3,
         };
       }));
    response.json({matches});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});

exports.getweeksmatches1=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const date: string | undefined = queryParams["date"] as string;
    if (!date) {
response.status(400).json({ error: "uid and date are required" });
        return;
    }
    const followingUids: string[] = [];
    const clubSnapshot = await admin.firestore()
      .collection("Professionals").doc(currentUserUid).collection("club").get();
        clubSnapshot.forEach((doc) => {
          followingUids.push(doc.id);
      });
      const t = new Date(date);
      // Calculate start of the week (Sunday)
      const startOfWeek = new Date(t);
      startOfWeek.setDate(t.getDate() - t.getDay()-1);
      startOfWeek.setHours(0, 0, 0, 0);
      // Calculate end of the week (Saturday)
      const endOfWeek = new Date(startOfWeek);
      endOfWeek.setDate(startOfWeek.getDate() + 6);
      endOfWeek.setHours(23, 59, 59, 999);
   //const today= admin.firestore.Timestamp.fromDate(t); 
      
      const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);

      const chunkArray = (array: string[], size: number) => {
        const result = [];
        for (let i = 0; i < array.length; i += size) {
          result.push(array.slice(i, i + size));
        }
        return result;
      };
   
      const uidChunks = chunkArray(uniqueUids, 30);
      const postsPromises = uidChunks.map(async (uids) => {
       const postsQuery = await admin.firestore().collection("Matches")
           .where("authorId", "in", uids)
           .where('scheduledDate','>=', startOfWeek)
           .where('scheduledDate',"<=",endOfWeek)
          .orderBy("createdAt", "desc")
          .get();
           return postsQuery.docs.map((doc) => ({
             matchId: doc.id,
             createdAt: doc.data().createdAt, 
             authorId: doc.data().authorId,
             location: doc.data().location,
             matchUrl: doc.data().matchUrl,
             activeuser: doc.data().activeuser,
             club1Id: doc.data().club1Id,
             club2Id: doc.data().club2Id,
             duration: doc.data().duration,
             leagueId: doc.data().leagueId,
             leaguematchId: doc.data().leaguematchId,
             match1Id: doc.data().match1Id,
             message: doc.data().message,
             pausetime: doc.data().pausetime,
             resumetime: doc.data().resumetime,
             scheduledDate: doc.data().scheduledDate, 
             score1: doc.data().score1,
             score2: doc.data().score2,
             starttime: doc.data().starttime,
             state1: doc.data().state1,
             state2: doc.data().state2,
             stoptime: doc.data().stoptime,
             time: doc.data().time,
             title: doc.data().title,
         }))});
   
       const postsArray = await Promise.all(postsPromises);
       const posts = ([] as any[]).concat(...postsArray);
   
       const matches = await Promise.all(posts.map(async (post) => {
         const userData1 = await fetchUserData(post.club1Id);
         const userData2= await  fetchUserData(post.club2Id);
         const userData3= await  fetchUserData(post.leagueId);
         // Merge user data into the post object
         return {
             ...post,
             club1: userData1,
             club2: userData2,
             league: userData3,
             
         };
       }));

    response.json({matches});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});
//weeks events
exports.getweeksevents=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const date: string | undefined = queryParams["date"] as string;
    if (!date) {
response.status(400).json({ error: "date are required" });
        return;
    }
    const followingUids: string[] = [currentUserUid];
    
    const t = new Date(date);
    // Calculate start of the week (Sunday)
    const startOfWeek = new Date(t);
    startOfWeek.setDate(t.getDate() - t.getDay()-1);
    startOfWeek.setHours(0, 0, 0, 0);
    // Calculate end of the week (Saturday)
    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(startOfWeek.getDate() + 6);
    endOfWeek.setHours(23, 59, 59, 999);
   //const today= admin.firestore.Timestamp.fromDate(t); 
      const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);

      const chunkArray = (array: string[], size: number) => {
        const result = [];
        for (let i = 0; i < array.length; i += size) {
          result.push(array.slice(i, i + size));
        }
        return result;
      };
   
      const uidChunks = chunkArray(uniqueUids, 30);
      const postsPromises = uidChunks.map(async (uids) => {
       const postsQuery = await admin.firestore().collection("Events")
       .where("authorId", "in", uids)
       .where('scheduledDate','>=', startOfWeek)
       .where('scheduledDate',"<=",endOfWeek)
      .orderBy("createdAt", "desc")
      .get();
       
   
           return postsQuery.docs.map((doc) => ({
             eventId: doc.id,
             createdAt: doc.data().createdAt, 
             location: doc.data().location,
             authorId: doc.data().authorId,
             eventUrl: doc.data().eventUrl,
             activeuser: doc.data().activeuser,
             duration: doc.data().duration,
             message: doc.data().message,
             pausetime: doc.data().pausetime,
             resumetime: doc.data().resumetime,
             scheduledDate: doc.data().scheduledDate, 
             starttime: doc.data().starttime,
             state1: doc.data().state1,
             state2: doc.data().state2,
             stoptime: doc.data().stoptime,
             time: doc.data().time,
             title: doc.data().title,
         }))});
   
       const postsArray = await Promise.all(postsPromises);
       const posts = ([] as any[]).concat(...postsArray);
   
       const events = await Promise.all(posts.map(async (post) => {
         const userData1 = await fetchUserData(post.authorId);
           // Merge user data into the post object
           return {
               ...post,
          author:userData1,
               
           };
       }));
      response.json({events});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});


exports.getweeksevents1=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const date: string | undefined = queryParams["date"] as string;
    if (!date) {
      response.status(400).json({ error: "date are required" });
        return;
    }
    const followingUids: string[] = [];
      const clubSnapshot = await admin.firestore()
        .collection("Professionals").doc(currentUserUid).collection("club").get();
          clubSnapshot.forEach((doc) => {
            followingUids.push(doc.id);
        });
        const t = new Date(date);
        // Calculate start of the week (Sunday)
        const startOfWeek = new Date(t);
        startOfWeek.setDate(t.getDate() - t.getDay()-1);
        startOfWeek.setHours(0, 0, 0, 0);
        // Calculate end of the week (Saturday)
        const endOfWeek = new Date(startOfWeek);
        endOfWeek.setDate(startOfWeek.getDate() + 6);
        endOfWeek.setHours(23, 59, 59, 999);
   //const today= admin.firestore.Timestamp.fromDate(t);     
    const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);

    const chunkArray = (array: string[], size: number) => {
      const result = [];
      for (let i = 0; i < array.length; i += size) {
        result.push(array.slice(i, i + size));
      }
      return result;
    };
 
    const uidChunks = chunkArray(uniqueUids, 30);
    const postsPromises = uidChunks.map(async (uids) => {
     const postsQuery = await admin.firestore().collection("Events")
     .where("authorId", "in", uids)
     .where('scheduledDate','>=', startOfWeek)
         .where('scheduledDate',"<=",endOfWeek)
        .orderBy("createdAt", "desc")
        .get();
     
 
         return postsQuery.docs.map((doc) => ({
           eventId: doc.id,
           createdAt: doc.data().createdAt, 
           location: doc.data().location,
           authorId: doc.data().authorId,
           eventUrl: doc.data().eventUrl,
           activeuser: doc.data().activeuser,
           duration: doc.data().duration,
           message: doc.data().message,
           pausetime: doc.data().pausetime,
           resumetime: doc.data().resumetime,
           scheduledDate: doc.data().scheduledDate, 
           starttime: doc.data().starttime,
           state1: doc.data().state1,
           state2: doc.data().state2,
           stoptime: doc.data().stoptime,
           time: doc.data().time,
           title: doc.data().title,
       }))});
 
     const postsArray = await Promise.all(postsPromises);
     const posts = ([] as any[]).concat(...postsArray);
 
     const events = await Promise.all(posts.map(async (post) => {
       const userData1 = await fetchUserData(post.authorId);
         // Merge user data into the post object
         return {
             ...post,
          author: userData1,
             
         };
     }));
      response.json({events});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});
//Upcoming matches
exports.getUpcomingmatches=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const date: string | undefined = queryParams["date"] as string;

    if (!currentUserUid || !date) {
response.status(400).json({ error: "uid and date are required" });
        return;
    }

    const followingUids: string[] = [currentUserUid];
    const clubSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("clubs").get();

    clubSnapshot.forEach((doc) => {
      const followingData = doc.data().clubs as { userId: string }[];
      followingData.forEach((clubs) => {
        followingUids.push(clubs.userId);
      });
    });
    const profesSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("professionals").get();

    profesSnapshot.forEach((doc) => {
      const followingData = doc.data().professionals as { userId: string }[];
      followingData.forEach((professionals) => {
        followingUids.push(professionals.userId);
      });
    });
    const today: Date = new Date(date);
    const startOfWeek = new Date(today);
    startOfWeek.setDate(today.getDate() - today.getDay()-1);
    startOfWeek.setHours(0, 0, 0, 0);
    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(startOfWeek.getDate() + 6);
    endOfWeek.setHours(23, 59, 59, 999);
    
    const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);

    const chunkArray = (array: string[], size: number) => {
      const result = [];
      for (let i = 0; i < array.length; i += size) {
        result.push(array.slice(i, i + size));
      }
      return result;
    };
 
    const uidChunks = chunkArray(uniqueUids, 30);
    const postsPromises = uidChunks.map(async (uids) => {
     const postsQuery = await admin.firestore().collection("Matches")
         .where("authorId", "in", uids)
         .where('scheduledDate', ">", today)
      .where('scheduledDate', "<=", endOfWeek)
      .orderBy("createdAt", "desc")
      .get();
         return postsQuery.docs.map((doc) => ({
           matchId: doc.id,
           createdAt: doc.data().createdAt, 
           authorId: doc.data().authorId,
           location: doc.data().location,
           matchUrl: doc.data().matchUrl,
           activeuser: doc.data().activeuser,
           club1Id: doc.data().club1Id,
           club2Id: doc.data().club2Id,
           duration: doc.data().duration,
           leagueId: doc.data().leagueId,
           leaguematchId: doc.data().leaguematchId,
           match1Id: doc.data().match1Id,
           message: doc.data().message,
           pausetime: doc.data().pausetime,
           resumetime: doc.data().resumetime,
           scheduledDate: doc.data().scheduledDate, 
           score1: doc.data().score1,
           score2: doc.data().score2,
           starttime: doc.data().starttime,
           state1: doc.data().state1,
           state2: doc.data().state2,
           stoptime: doc.data().stoptime,
           time: doc.data().time,
           title: doc.data().title,
       }))});
 
     const postsArray = await Promise.all(postsPromises);
     const posts = ([] as any[]).concat(...postsArray);
 
     const matches = await Promise.all(posts.map(async (post) => {
       const userData1 = await fetchUserData(post.club1Id);
       const userData2= await  fetchUserData(post.club2Id);
       const userData3= await  fetchUserData(post.leagueId);
       // Merge user data into the post object
       return {
           ...post,
           club1: userData1,
        club2: userData2,
        league: userData3,
           
       };
     }));

    response.json({matches});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});
//upcoming events
exports.getUpcomingevents=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const date: string | undefined = queryParams["date"] as string;

    if (!currentUserUid || !date) {
response.status(400).json({ error: "uid and date are required" });
        return;
    }

    const followingUids: string[] = [currentUserUid];
    const clubSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("clubs").get();

    clubSnapshot.forEach((doc) => {
      const followingData = doc.data().clubs as { userId: string }[];
      followingData.forEach((clubs) => {
        followingUids.push(clubs.userId);
      });
    });

    const profesSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("professionals").get();

    profesSnapshot.forEach((doc) => {
      const followingData = doc.data().professionals as { userId: string }[];
      followingData.forEach((professionals) => {
        followingUids.push(professionals.userId);
      });
    });
    const today: Date = new Date(date);
    const startOfWeek = new Date(today);
    startOfWeek.setDate(today.getDate() - today.getDay()-1);
    startOfWeek.setHours(0, 0, 0, 0);
    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(startOfWeek.getDate() + 6);
    endOfWeek.setHours(23, 59, 59, 999);
   
    const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);

    const chunkArray = (array: string[], size: number) => {
      const result = [];
      for (let i = 0; i < array.length; i += size) {
        result.push(array.slice(i, i + size));
      }
      return result;
    };
 
    const uidChunks = chunkArray(uniqueUids, 30);
    const postsPromises = uidChunks.map(async (uids) => {
     const postsQuery = await admin.firestore().collection("Events")
     .where("authorId", "in", uids)
     .where('scheduledDate', ">", today)
     .where('scheduledDate', "<=", endOfWeek)
     .orderBy("createdAt", "desc")
     .get();
     
 
         return postsQuery.docs.map((doc) => ({
           eventId: doc.id,
           createdAt: doc.data().createdAt, 
           location: doc.data().location,
           authorId: doc.data().authorId,
           eventUrl: doc.data().eventUrl,
           activeuser: doc.data().activeuser,
           duration: doc.data().duration,
           message: doc.data().message,
           pausetime: doc.data().pausetime,
           resumetime: doc.data().resumetime,
           scheduledDate: doc.data().scheduledDate, 
           starttime: doc.data().starttime,
           state1: doc.data().state1,
           state2: doc.data().state2,
           stoptime: doc.data().stoptime,
           time: doc.data().time,
           title: doc.data().title,
       }))});
 
     const postsArray = await Promise.all(postsPromises);
     const posts = ([] as any[]).concat(...postsArray);
 
     const events = await Promise.all(posts.map(async (post) => {
       const userData1 = await fetchUserData(post.authorId);
         // Merge user data into the post object
         return {
             ...post,
          author:userData1,
             
         };
     }));

    response.json({events});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});
//Past matches
exports.getPastmatches=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const date: string | undefined = queryParams["date"] as string;

    if (!currentUserUid || !date) {
response.status(400).json({ error: "uid and date are required" });
        return;
    }
    const followingUids: string[] = [currentUserUid];
    const clubSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("clubs").get();
    clubSnapshot.forEach((doc) => {
      const followingData = doc.data().clubs as { userId: string }[];
      followingData.forEach((clubs) => {
        followingUids.push(clubs.userId);
      });
    });

    const profesSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("professionals").get();

    profesSnapshot.forEach((doc) => {
      const followingData = doc.data().professionals as { userId: string }[];
      followingData.forEach((professionals) => {
        followingUids.push(professionals.userId);
      });
    });
    const now: Date = new Date(date);
    const yesterday = new Date(now);
    yesterday.setDate(now.getDate() - 2);
    yesterday.setHours(23, 59, 59, 999); 
    const sevenDaysAgo: Date = new Date(now);
    sevenDaysAgo.setDate(now.getDate() - 7);
    sevenDaysAgo.setHours(0, 0, 0, 0);     
  
    const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);

    const chunkArray = (array: string[], size: number) => {
      const result = [];
      for (let i = 0; i < array.length; i += size) {
        result.push(array.slice(i, i + size));
      }
      return result;
    };
 
    const uidChunks = chunkArray(uniqueUids, 30);
    const postsPromises = uidChunks.map(async (uids) => {
     const postsQuery = await admin.firestore().collection("Matches")
         .where("authorId", "in", uids)
         .where('scheduledDate', ">=", sevenDaysAgo)
         .where('scheduledDate', "<=", yesterday)
         .orderBy("createdAt", "desc")
         .get();
         return postsQuery.docs.map((doc) => ({
           matchId: doc.id,
           createdAt: doc.data().createdAt, 
           authorId: doc.data().authorId,
           location: doc.data().location,
           matchUrl: doc.data().matchUrl,
           activeuser: doc.data().activeuser,
           club1Id: doc.data().club1Id,
           club2Id: doc.data().club2Id,
           duration: doc.data().duration,
           leagueId: doc.data().leagueId,
           leaguematchId: doc.data().leaguematchId,
           match1Id: doc.data().match1Id,
           message: doc.data().message,
           pausetime: doc.data().pausetime,
           resumetime: doc.data().resumetime,
           scheduledDate: doc.data().scheduledDate, 
           score1: doc.data().score1,
           score2: doc.data().score2,
           starttime: doc.data().starttime,
           state1: doc.data().state1,
           state2: doc.data().state2,
           stoptime: doc.data().stoptime,
           time: doc.data().time,
           title: doc.data().title,
       }))});
 
     const postsArray = await Promise.all(postsPromises);
     const posts = ([] as any[]).concat(...postsArray);
 
     const matches = await Promise.all(posts.map(async (post) => {
       const userData1 = await fetchUserData(post.club1Id);
       const userData2= await  fetchUserData(post.club2Id);
       const userData3= await  fetchUserData(post.leagueId);
       // Merge user data into the post object
       return {
           ...post,
           club1: userData1,
           club2: userData2,
           league: userData3,
           
       };
     }));

    response.json({matches});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});
//past events
exports.getPastevents=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const date: string | undefined = queryParams["date"] as string;

    if (!currentUserUid || !date) {
response.status(400).json({ error: "uid and date are required" });
        return;
    }
    const followingUids: string[] = [currentUserUid];
    const clubSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("clubs").get();
    clubSnapshot.forEach((doc) => {
      const followingData = doc.data().clubs as { userId: string }[];
      followingData.forEach((clubs) => {
        followingUids.push(clubs.userId);
      });
    });
    const profesSnapshot = await admin.firestore()
      .collection("Fans").doc(currentUserUid).collection("professionals").get();

    profesSnapshot.forEach((doc) => {
      const followingData = doc.data().professionals as { userId: string }[];
      followingData.forEach((professionals) => {
        followingUids.push(professionals.userId);
      });
    });
    const now: Date = new Date(date);
    const yesterday = new Date(now);
    yesterday.setDate(now.getDate() - 2);
    yesterday.setHours(23, 59, 59, 999); 
    const sevenDaysAgo: Date = new Date(now);
    sevenDaysAgo.setDate(now.getDate() - 7);
    sevenDaysAgo.setHours(0, 0, 0, 0); 
  
    const uniqueUids = Array.from(new Set(followingUids)).filter(Boolean);

    const chunkArray = (array: string[], size: number) => {
      const result = [];
      for (let i = 0; i < array.length; i += size) {
        result.push(array.slice(i, i + size));
      }
      return result;
    };
 
    const uidChunks = chunkArray(uniqueUids, 30);
    const postsPromises = uidChunks.map(async (uids) => {
     const postsQuery = await admin.firestore().collection("Events")
     .where("authorId", "in", uids)
     .where('scheduledDate', ">=", sevenDaysAgo)
     .where('scheduledDate', "<=", yesterday)
     .orderBy("createdAt", "desc")
     .get();
     
 
         return postsQuery.docs.map((doc) => ({
           eventId: doc.id,
           createdAt: doc.data().createdAt, 
           location: doc.data().location,
           authorId: doc.data().authorId,
           eventUrl: doc.data().eventUrl,
           activeuser: doc.data().activeuser,
           duration: doc.data().duration,
           message: doc.data().message,
           pausetime: doc.data().pausetime,
           resumetime: doc.data().resumetime,
           scheduledDate: doc.data().scheduledDate, 
           starttime: doc.data().starttime,
           state1: doc.data().state1,
           state2: doc.data().state2,
           stoptime: doc.data().stoptime,
           time: doc.data().time,
           title: doc.data().title,
       }))});
 
     const postsArray = await Promise.all(postsPromises);
     const posts = ([] as any[]).concat(...postsArray);
 
     const events = await Promise.all(posts.map(async (post) => {
       const userData1 = await fetchUserData(post.authorId);
         // Merge user data into the post object
         return {
             ...post,
             author:userData1,
             
         };
     }));

    response.json({events});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});
//my matches
exports.getmymatches=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string, string | string[]
    | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;

   

    if (!currentUserUid) {
response.status(400).json({ error: "uid and date are required" });
        return;
    }
    const postsQuery = await admin.firestore().collection("Matches")
      .where("authorId", "==", currentUserUid)
      .orderBy("createdAt", "desc")
      .limit(8)
      .get();

      const matches1 = postsQuery.docs.map((doc) => ({
        matchId: doc.id,
        createdAt: doc.data().createdAt, 
        authorId: doc.data().authorId,
        location: doc.data().location,
        matchUrl: doc.data().matchUrl,
        activeuser: doc.data().activeuser,
        club1Id: doc.data().club1Id,
        club2Id: doc.data().club2Id,
        duration: doc.data().duration,
        leagueId: doc.data().leagueId,
        leaguematchId: doc.data().leaguematchId,
        match1Id: doc.data().match1Id,
        message: doc.data().message,
        pausetime: doc.data().pausetime,
        resumetime: doc.data().resumetime,
        scheduledDate: doc.data().scheduledDate, 
        score1: doc.data().score1,
        score2: doc.data().score2,
        starttime: doc.data().starttime,
        state1: doc.data().state1,
        state2: doc.data().state2,
        stoptime: doc.data().stoptime,
        time: doc.data().time,
        title: doc.data().title,
    }));
    
    const matches = await Promise.all(matches1.map(async (post) => {
      // Fetch user data for each post's authorId
      const userData1 = await fetchUserData(post.club1Id);
      const userData2= await  fetchUserData(post.club2Id);
      const userData3= await  fetchUserData(post.leagueId);
      // Merge user data into the post object
      return {
          ...post,
          club1: userData1,
          club2: userData2,
          league: userData3,
          
      };
  }));
    response.json({matches});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});
//get myevents
exports.getmyevents=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string, string | string[]
    | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;

   

    if (!currentUserUid) {
response.status(400).json({ error: "uid and date are required" });
        return;
    }
    const postsQuery = await admin.firestore().collection("Events")
      .where("authorId", "==", currentUserUid)
      .orderBy("createdAt", "desc")
      .limit(8)
      .get();

     
      const matches1 = postsQuery.docs.map((doc) => ({
        eventId: doc.id,
        createdAt: doc.data().createdAt, 
        location: doc.data().location,
        authorId: doc.data().authorId,
        eventUrl: doc.data().eventUrl,
        activeuser: doc.data().activeuser,
        duration: doc.data().duration,
        message: doc.data().message,
        pausetime: doc.data().pausetime,
        resumetime: doc.data().resumetime,
        scheduledDate: doc.data().scheduledDate, 
        starttime: doc.data().starttime,
        state1: doc.data().state1,
        state2: doc.data().state2,
        stoptime: doc.data().stoptime,
        time: doc.data().time,
        title: doc.data().title,
    }));
    const events = await Promise.all(matches1.map(async (post) => {
      // Fetch user data for each post's authorId
      const userData1 = await fetchUserData(post.authorId);
      // Merge user data into the post object
      return {
          ...post,
          author:userData1,
          
      };
  }));

    response.json({events});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});
//more my matches
exports.getmoremymatches=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const lastdocId: string | undefined = queryParams["lastdocId"] as string;

    if (!currentUserUid || !lastdocId) {
response.status(400).json({ error: "uid and lastdocId are required" });
        return;
    }
    const lastDoc =await admin.firestore()
    .collection('Matches').doc(lastdocId).get();
    const postsQuery = await admin.firestore().collection("Matches")
      .where("authorId", "==", currentUserUid)
      .orderBy("createdAt", "desc")
      .startAfter(lastDoc)
      .limit(4)
      .get();

      const matches1 = postsQuery.docs.map((doc) => ({
        matchId: doc.id,
        createdAt: doc.data().createdAt, 
        authorId: doc.data().authorId,
        location: doc.data().location,
        matchUrl: doc.data().matchUrl,
        activeuser: doc.data().activeuser,
        club1Id: doc.data().club1Id,
        club2Id: doc.data().club2Id,
        duration: doc.data().duration,
        leagueId: doc.data().leagueId,
        leaguematchId: doc.data().leaguematchId,
        match1Id: doc.data().match1Id,
        message: doc.data().message,
        pausetime: doc.data().pausetime,
        resumetime: doc.data().resumetime,
        scheduledDate: doc.data().scheduledDate, 
        score1: doc.data().score1,
        score2: doc.data().score2,
        starttime: doc.data().starttime,
        state1: doc.data().state1,
        state2: doc.data().state2,
        stoptime: doc.data().stoptime,
        time: doc.data().time,
        title: doc.data().title,
    }));
    
    const matches = await Promise.all(matches1.map(async (post) => {
      // Fetch user data for each post's authorId
      const userData1 = await fetchUserData(post.club1Id);
      const userData2= await  fetchUserData(post.club2Id);
      const userData3= await  fetchUserData(post.leagueId);
      // Merge user data into the post object
      return {
          ...post,
          club1: userData1,
          club2: userData2,
          league: userData3,
          
      };
  }));
    response.json({matches});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});
//get moremyevents
exports.getmoremyevents=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const lastdocId: string | undefined = queryParams["lastdocId"] as string;

    if (!currentUserUid || !lastdocId) {
response.status(400).json({ error: "uid and lastdocId are required" });
        return;
    }
    const lastDoc =await admin.firestore()
    .collection('Matches').doc(lastdocId).get();
    const postsQuery = await admin.firestore().collection("Events")
      .where("authorId", "==", currentUserUid)
      .orderBy("createdAt", "desc")
      .startAfter(lastDoc)
      .limit(4)
      .get();
     
      const matches1 = postsQuery.docs.map((doc) => ({
        eventId: doc.id,
        createdAt: doc.data().createdAt, 
        location: doc.data().location,
        authorId: doc.data().authorId,
        eventUrl: doc.data().eventUrl,
        activeuser: doc.data().activeuser,
        duration: doc.data().duration,
        message: doc.data().message,
        pausetime: doc.data().pausetime,
        resumetime: doc.data().resumetime,
        scheduledDate: doc.data().scheduledDate, 
        starttime: doc.data().starttime,
        state1: doc.data().state1,
        state2: doc.data().state2,
        stoptime: doc.data().stoptime,
        time: doc.data().time,
        title: doc.data().title,
    }));
    const events = await Promise.all(matches1.map(async (post) => {
      // Fetch user data for each post's authorId
      const userData1 = await fetchUserData(post.authorId);
      // Merge user data into the post object
      return {
          ...post,
          author: userData1,
          
      };
  }));

    response.json({events});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});
//getfiltermatches

    //getfiltermatches
exports.getmatch=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const docId: string | undefined = queryParams["docId"] as string;
  
    if (!docId) {
response.status(400).json({ error: "docId, from and to are required" });
        return;
    }
    const postsQuery = await admin.firestore().collection("Matches")
      .where("matchId", "==", docId)
      .limit(1)
      .get();

      const matches1 = postsQuery.docs.map((doc) => ({
        matchId: doc.id,
        createdAt: doc.data().createdAt, 
        authorId: doc.data().authorId,
        location: doc.data().location,
        matchUrl: doc.data().matchUrl,
        activeuser: doc.data().activeuser,
        club1Id: doc.data().club1Id,
        club2Id: doc.data().club2Id,
        duration: doc.data().duration,
        leagueId: doc.data().leagueId,
        leaguematchId: doc.data().leaguematchId,
        match1Id: doc.data().match1Id,
        message: doc.data().message,
        pausetime: doc.data().pausetime,
        resumetime: doc.data().resumetime,
        scheduledDate: doc.data().scheduledDate, 
        score1: doc.data().score1,
        score2: doc.data().score2,
        starttime: doc.data().starttime,
        state1: doc.data().state1,
        state2: doc.data().state2,
        stoptime: doc.data().stoptime,
        time: doc.data().time,
        title: doc.data().title,
    }));
    
    const match = await Promise.all(matches1.map(async (post) => {
      // Fetch user data for each post's authorId
      const userData1 = await fetchUserData(post.club1Id);
      const userData2= await  fetchUserData(post.club2Id);
      const userData3= await  fetchUserData(post.leagueId);
      // Merge user data into the post object
      return {
          ...post,
          club1: userData1,
        club2: userData2,
        league: userData3,
          
      };
  }));
  const matches=match[0];
    response.json({matches});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});
//get event
exports.getevent=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const docId: string | undefined = queryParams["docId"] as string;
  
    if (!docId) {
response.status(400).json({ error: "docId, from and to are required" });
        return;
    }
    const postsQuery = await admin.firestore().collection("Events")
      .where("eventId", "==", docId)
      .limit(1)
      .get();

     
      const matches1 = postsQuery.docs.map((doc) => ({
        eventId: doc.id,
        createdAt: doc.data().createdAt, 
        location: doc.data().location,
        authorId: doc.data().authorId,
        eventUrl: doc.data().eventUrl,
        activeuser: doc.data().activeuser,
        duration: doc.data().duration,
        message: doc.data().message,
        pausetime: doc.data().pausetime,
        resumetime: doc.data().resumetime,
        scheduledDate: doc.data().scheduledDate, 
        starttime: doc.data().starttime,
        state1: doc.data().state1,
        state2: doc.data().state2,
        stoptime: doc.data().stoptime,
        time: doc.data().time,
        title: doc.data().title,
    }));
    const event = await Promise.all(matches1.map(async (post) => {
      // Fetch user data for each post's authorId
      const userData1 = await fetchUserData(post.authorId);
      // Merge user data into the post object
      return {
          ...post,
         author: userData1,
          
      };
  }));
  const events=event[0];
    response.json({events});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});

//get filter matches
exports.getfiltermatches=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const from: string | undefined = queryParams["from"] as string;
    const to: string | undefined = queryParams["to"] as string;
    if (!currentUserUid || !from||!to) {
response.status(400).json({ error: "uid, from and to are required" });
        return;
    }
    const fromD: Date = new Date(from);
    const toD: Date = new Date(to)
     fromD.setHours(0, 0, 0, 0);
     toD.setHours(0, 0, 0, 0);
    const postsQuery = await admin.firestore().collection("Matches")
      .where("authorId", "==", currentUserUid)
      .where('scheduledDate', ">=", fromD)
      .where('scheduledDate', "<=", toD)
      .orderBy("createdAt", "desc")
      .limit(8)
      .get();

      const matches1 = postsQuery.docs.map((doc) => ({
        matchId: doc.id,
        createdAt: doc.data().createdAt, 
        authorId: doc.data().authorId,
        location: doc.data().location,
        matchUrl: doc.data().matchUrl,
        activeuser: doc.data().activeuser,
        club1Id: doc.data().club1Id,
        club2Id: doc.data().club2Id,
        duration: doc.data().duration,
        leagueId: doc.data().leagueId,
        leaguematchId: doc.data().leaguematchId,
        match1Id: doc.data().match1Id,
        message: doc.data().message,
        pausetime: doc.data().pausetime,
        resumetime: doc.data().resumetime,
        scheduledDate: doc.data().scheduledDate, 
        score1: doc.data().score1,
        score2: doc.data().score2,
        starttime: doc.data().starttime,
        state1: doc.data().state1,
        state2: doc.data().state2,
        stoptime: doc.data().stoptime,
        time: doc.data().time,
        title: doc.data().title,
    }
  )
  );
    const matches = await Promise.all(matches1.map(async (post) => {
      // Fetch user data for each post's authorId
      const userData1 = await fetchUserData(post.club1Id);
      const userData2= await  fetchUserData(post.club2Id);
      const userData3= await  fetchUserData(post.leagueId);
      // Merge user data into the post object
      return {
          ...post,
          club1: userData1,
          club2: userData2,
          league: userData3,   
      };
  }));
    response.json({matches});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});

//get filter events
exports.getfilterevents=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const currentUserUid: string | undefined = queryParams["uid"] as string;
    const from: string | undefined = queryParams["from"] as string;
    const to: string | undefined = queryParams["to"] as string;
    if (!currentUserUid || !from||!to) {
response.status(400).json({ error: "uid, from and to are required" });
        return;
    }
    const fromD: Date = new Date(from);
    const toD: Date = new Date(to)
     fromD.setHours(0, 0, 0, 0);
     toD.setHours(0, 0, 0, 0);
    const postsQuery = await admin.firestore().collection("Events")
      .where("authorId", "==", currentUserUid)
      .where('scheduledDate', ">=", fromD)
      .where('scheduledDate', "<=", toD)
      .orderBy("createdAt", "desc")
      .limit(8)
      .get();

      
      const matches1 = postsQuery.docs.map((doc) => ({
        eventId: doc.id,
        createdAt: doc.data().createdAt, 
        location: doc.data().location,
        authorId: doc.data().authorId,
        eventUrl: doc.data().eventUrl,
        activeuser: doc.data().activeuser,
        duration: doc.data().duration,
        message: doc.data().message,
        pausetime: doc.data().pausetime,
        resumetime: doc.data().resumetime,
        scheduledDate: doc.data().scheduledDate, 
        starttime: doc.data().starttime,
        state1: doc.data().state1,
        state2: doc.data().state2,
        stoptime: doc.data().stoptime,
        time: doc.data().time,
        title: doc.data().title,
       
    }));
    const events = await Promise.all(matches1.map(async (post) => {
      // Fetch user data for each post's authorId
      const userData1 = await fetchUserData(post.authorId);
      // Merge user data into the post object
      return {
          ...post,
        author:userData1,
          
      };
  }));

    response.json({events});
  } catch (error) {
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
  }
});
//get likes
exports.getlikesdata=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const docId: string | undefined = queryParams["docId"] as string;
    const collectionName: string | 
    undefined = queryParams["collection"] as string;
    const subcollectionName: string | 
    undefined = queryParams["subcollection"] as string;
    if (!docId || !collectionName||!subcollectionName) {
          response.status(400).json({ 
  error: "docId, collectionName and subcollectionName are required" });
        return;
    }
    interface likes {
      userId: string;
      timestamp: FirebaseFirestore.Timestamp;
  }
  
  const likes1: { userId: string; 
    timestamp: FirebaseFirestore.Timestamp }[] = [];
  
  const profesSnapshot = await admin.firestore()
      .collection(collectionName)
      .doc(docId)
      .collection(subcollectionName)
      .get();
  
  profesSnapshot.forEach((doc) => {
      const followingData = doc.data().likes as likes[];
      followingData.forEach((professionals) => {
          likes1.push({
              userId: professionals.userId,
              timestamp: professionals.timestamp
          });
      });
  });
  const likes= await Promise.all(likes1.map( async(d)=>{
    const userData1 = await fetchUserData(d.userId);
    return{
      userId: d.userId,
      timestamp: d.timestamp,
      author:userData1,
    }

  }));
  response.json({likes});
  }catch(error){
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
    }});
    //get likes,fans,clubs,professionals
    exports.getcommentsdata=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const docId: string | undefined = queryParams["docId"] as string;
    const collectionName: string |
     undefined = queryParams["collection"] as string;
    const subcollectionName: string | 
    undefined = queryParams["subcollection"] as string;
    if (!docId || !collectionName||!subcollectionName) {
response.status(400).json({
   error: "docId, collectionName and subcollectionName are required" });
        return;
    }
    interface comments {
      userId: string;
      createdAt: FirebaseFirestore.Timestamp;
      comment:string;
      commentId:string;
            
  }
  
  const comments1: { userId: string;
     createdAt: FirebaseFirestore.Timestamp;
     comment:string;commentId:string}[] = [];
  
  const profesSnapshot = await admin.firestore()
      .collection(collectionName)
      .doc(docId)
      .collection(subcollectionName)
      .get();
  
  profesSnapshot.forEach((doc) => {
      const followingData = doc.data().comments as comments[];
      followingData.forEach((professionals) => {
          comments1.push({
              userId: professionals.userId,
              createdAt: professionals.createdAt,
              comment:professionals.comment,
              commentId:professionals.commentId
          });
      });
  });
  const comments= await Promise.all(comments1.map( async(d)=>{
    const userData1 = await fetchUserData(d.userId);
    return{
      userId:d.userId,
      createdAt:d.createdAt,
      comment:d.comment,
      commentId:d.commentId,
      author: userData1,
    }

  }));
  response.json({comments});
  }catch(error){
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
    }});
exports.getreplydata=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const docId: string | undefined = queryParams["docId"] as string;
    const collectionName: string | 
    undefined = queryParams["collection"] as string;
    const subcollectionName: string | 
    undefined = queryParams["subcollection"] as string;
    const commentId:string |undefined=queryParams["commentId"]as string;
    if (!docId || !collectionName||!subcollectionName||!commentId) {
response.status(400).json({
   error: "docId, collectionName and subcollectionName are required" });
        return;
    }
    interface replies {
      userId: string;
      createdAt: FirebaseFirestore.Timestamp;
      reply:string;
      commentId:string;
      replyId:string;
            
  }
  const replies1: { userId: string; 
    createdAt: FirebaseFirestore.Timestamp;
    reply:string;commentId:string;replyId:string}[] = [];
  const profesSnapshot = await admin.firestore()
      .collection(collectionName)
      .doc(docId)
      .collection(subcollectionName)
      .get();
  
  profesSnapshot.forEach((doc) => {
      const followingData = doc.data().replies as replies[];
      followingData.forEach((professionals) => {
        if(professionals.commentId==commentId){
          replies1.push({
              userId: professionals.userId,
              createdAt: professionals.createdAt,
              reply:professionals.reply,
              commentId:professionals.commentId,
              replyId:professionals.replyId,
          });}
      });
  });
  const replies= await Promise.all(replies1.map( async(d)=>{
    const userData1 = await fetchUserData(d.userId);
    return{
      userId: d.userId,
      createdAt: d.createdAt,
      reply:d.reply,
      commentId:d.commentId,
      replyId:d.replyId,
      author: userData1,
    }

  }));
  response.json({replies});
  }catch(error){
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
    }});
//fans,clubs,followers,following,professionals,
exports.getanydata=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const docId: string | undefined = queryParams["docId"] as string;
    const collectionName: string | 
    undefined = queryParams["collection"] as string;
    const subcollectionName: string |
     undefined = queryParams["subcollection"] as string;
    if (!docId || !collectionName||!subcollectionName) {
response.status(400).json({ 
  error: "docId, collectionName and subcollectionName are required" });
        return;
    }
 
  const profesSnapshot = await admin.firestore()
      .collection(collectionName)
      .doc(docId)
      .collection(subcollectionName)
      .get();
  if(subcollectionName=="fans"){
      interface fans {
        userId: string;
        timestamp: FirebaseFirestore.Timestamp;
    }
    
    const fans1: {userId:string;
      timestamp:FirebaseFirestore.Timestamp }[] = [];
    
  profesSnapshot.forEach((doc) => {
      const followingData = doc.data().fans as fans[];
      followingData.forEach((professionals) => {
          fans1.push({
              userId: professionals.userId,
              timestamp: professionals.timestamp
          });
      });
  });
  const data = await Promise.all(
    fans1.map(async (d) => {
      const userData1 = await fetchUserData(d.userId);
      return {
        userId: d.userId,
        timestamp: d.timestamp,
        author: userData1,
      };
    })
  );
  
  response.json({data});
}else if(subcollectionName=="professionals"){
  interface professionals {
    userId: string;
    timestamp: FirebaseFirestore.Timestamp;
}

const professinals1:{userId:string;
  timestamp:FirebaseFirestore.Timestamp}[] = [];

profesSnapshot.forEach((doc) => {
  const followingData = doc.data().professionals as professionals[];
  followingData.forEach((profe) => {
      professinals1.push({
          userId: profe.userId,
          timestamp: profe.timestamp
      });
  });
});
const data = await Promise.all(
  professinals1.map(async (d) => {
    const userData1 = await fetchUserData(d.userId);
    return {
      userId: d.userId,
      timestamp: d.timestamp,
      author: userData1,
    };
  })
);

response.json({data});
}else if(subcollectionName=="clubs"){
  interface clubs {
    userId: string;
    timestamp: FirebaseFirestore.Timestamp;
}

const clubs1: { userId:string;timestamp:FirebaseFirestore.Timestamp }[] = [];

profesSnapshot.forEach((doc) => {
  const followingData = doc.data().clubs as clubs[];
  followingData.forEach((profe) => {
      clubs1.push({
          userId: profe.userId,
          timestamp: profe.timestamp
      });
  });
});
const data = await Promise.all(
  clubs1.map(async (d) => {
    const userData1 = await fetchUserData(d.userId);
    return {
      userId: d.userId,
      timestamp: d.timestamp,
      author: userData1,
    };
  })
);

response.json({data});
}else if(subcollectionName=="following"){
  interface following {
    userId: string;
    timestamp: FirebaseFirestore.Timestamp;
}

const clubs1: { userId:string;timestamp:FirebaseFirestore.Timestamp }[] = [];

profesSnapshot.forEach((doc) => {
  const followingData = doc.data().following as following[];
  followingData.forEach((profe) => {
      clubs1.push({
          userId: profe.userId,
          timestamp: profe.timestamp
      });
  });
});
const data = await Promise.all(
  clubs1.map(async (d) => {
    const userData1 = await fetchUserData(d.userId);
    return {
      userId: d.userId,
      timestamp: d.timestamp,
     author: userData1,
    };
  })
);

response.json({data});
}else if(subcollectionName=="followers"){
  interface followers {
    userId: string;
    timestamp: FirebaseFirestore.Timestamp;
}

const clubs1: { userId:string;timestamp:FirebaseFirestore.Timestamp }[] = [];

profesSnapshot.forEach((doc) => {
  const followingData = doc.data().followers as followers[];
  followingData.forEach((profe) => {
      clubs1.push({
          userId: profe.userId,
          timestamp: profe.timestamp
      });
  });
});
const data = await Promise.all(
  clubs1.map(async (d) => {
    const userData1 = await fetchUserData(d.userId);
    return {
      userId: d.userId,
      timestamp: d.timestamp,
      author: userData1,
    };
  })
);
response.json({data}); 
}else if(subcollectionName=="notifications"){
  interface notifications {
   NotifiId: string;
    createdAt: FirebaseFirestore.Timestamp;
    message:string;
    from:string;
    to:string;
    content:string;
}

const notification: {NotifiId: string;
  createdAt: FirebaseFirestore.Timestamp;
  message:string;
  from:string;
  to:string;
  content:string; }[] = [];

profesSnapshot.forEach((doc) => {
  const followingData = doc.data().notifications as notifications[];
  followingData.forEach((profe) => {
    notification.push({
          NotifiId: profe.NotifiId,
          createdAt: profe.createdAt,
          content:profe.content,
          message:profe.message,
          from:profe.from,
          to:profe.to,
      });
  });
});
const data = await Promise.all(
  notification.map(async (d) => {
    const userDataf = await fetchUserData(d.from);
    const userDatat = await fetchUserData(d.to);
    return {
    NotifiId:d.NotifiId,
    content:d.content,
    message:d.message,
    createdAt:d.createdAt,
    from:userDataf,
    to:userDatat,
    };
  })
);
response.json({data}); 

}
  }catch(error){
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
    }});

//getsuggesteddata
exports.getsuggesteddata = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams = convertParsedQs(request.query);
    const currentUserUid = queryParams["uid"] as string;
    if (!currentUserUid) {
      response.status(400).json({ error: "uid, are required" });
      return;
    }

    //let longitude;
    //let latitude;
  
    const userDoc = await admin.firestore().collection("Fans").doc(currentUserUid).get();
    if (userDoc.exists) {
      const data = userDoc.data();
      if (data != undefined) {
        const latitude = data.clatitude;
        const longitude = data.clongitude;
        const following:string[]=[];
        const collectUids = (snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>, key: string) => {
          snapshot.forEach((doc) => {
            const followingData = doc.data()[key] as { userId: string }[];
            followingData.forEach((item) => {
              if (item.userId) {
                following.push(item.userId);
              }
            });
          });
        };
        const followingSnapshot = await admin.firestore().collection("Fans").doc(currentUserUid).collection("following").get();
            collectUids(followingSnapshot, 'following');
            const followingSnapshot1 = await admin.firestore().collection("Fans").doc(currentUserUid).collection("clubs").get();
            collectUids(followingSnapshot1, 'clubs');
            const followingSnapshot2 = await admin.firestore().collection("Fans").doc(currentUserUid).collection("professionals").get();
            collectUids(followingSnapshot2, 'professionals');
        const postsQuery = await admin.firestore().collection("Clubs")
          .where('clatitude', ">=", latitude - 0.5)
          .where('clatitude', "<=", latitude + 0.5)
          .where('clongitude', ">=", longitude - 0.5)
          .where('clongitude', "<=", longitude + 0.5)
          .orderBy("createdAt", "desc")
          .limit(2)
          .get();

        const postsQuery1 = await admin.firestore().collection("Fans")
          .where('clatitude', ">=", latitude - 0.5)
          .where('clatitude', "<=", latitude + 0.5)
          .where('clongitude', ">=", longitude - 0.5)
          .where('clongitude', "<=", longitude + 0.5)
          .orderBy("createdAt", "desc")
          .limit(2)
          .get();

        const postsQuery2 = await admin.firestore().collection("Professionals")
          .where('clatitude', ">=", latitude - 0.5)
          .where('clatitude', "<=", latitude + 0.5)
          .where('clongitude', ">=", longitude - 0.5)
          .where('clongitude', "<=", longitude + 0.5)
          .orderBy("createdAt", "desc")
          .limit(2)
          .get();

        let users1 = postsQuery.docs.map((doc) => ({
          userId: doc.id,
          createdAt: doc.data().createdAt,
          location: doc.data().Location,
          name: doc.data().Clubname,
          genre: doc.data().genre,
          url: doc.data().profileimage,
          collection:"Club",
        }));

        let users2 = postsQuery1.docs.map((doc) => ({
          userId: doc.id,
          createdAt: doc.data().createdAt,
          location: doc.data().location,
          name: doc.data().username,
          genre: doc.data().genre,
          url: doc.data().profileimage,
          collection:"Fan",
        }));

        let users3 = postsQuery2.docs.map((doc) => ({
          userId: doc.id,
          createdAt: doc.data().createdAt,
          location: doc.data().Location,
          name: doc.data().Stagename,
          genre: doc.data().genre,
          url: doc.data().profileimage,
          collection:"Professional",
        }));

        // Filter out users who are already being followed
        users1 = users1.filter(user => !following.includes(user.userId));
        users2 = users2.filter(user => !following.includes(user.userId));
        users3 = users3.filter(user => !following.includes(user.userId));

        const users = [...users1, ...users2, ...users3];
        response.json({ users });
      }
    }

  } catch (error) {
    console.error("Error getting suggetions:", error);
    response.status(500).json({ error: "Failed to get suggetions: " + error });
  }
});


// Define API URLs and collection names
const currentDateAsString = getCurrentDateAsString();
const apiUrls = {
  football: 'https://v3.football.api-sports.io/fixtures?live=all',
  volleyball: 'https://v1.volleyball.api-sports.io/games?date='
  +currentDateAsString,
  basketball: 'https://v1.basketball.api-sports.io/games?date='
  +currentDateAsString,
  nba:"https://v2.nba.api-sports.io/games?date="+currentDateAsString,
  rugby:"https://v1.rugby.api-sports.io/games?date="+currentDateAsString,
  formula1:"https://v1.formula-1.api-sports.io/races?season="
  +currentDateAsString,
  baseball:"https://v1.baseball.api-sports.io/games?date="+currentDateAsString,
  handball:"https://v1.handball.api-sports.io/games?date="+currentDateAsString,
  americanfootball:"https://v1.american-football.api-sports.io/games?date="
  +currentDateAsString,
  hockey:"https://v1.hockey.api-sports.io/games?date="+currentDateAsString,
  // Add more sports and their corresponding API URLs here
};
function getCurrentDateAsString(): string {
  const today = new Date();
  const year = today.getFullYear();
  const month = (today.getMonth() + 1).toString().padStart(2, '0'); 
  const day = today.getDate().toString().padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// Usage

const collectionNames = {
  football: 'Football',
  volleyball: 'Volleyball',
  basketball: 'Basketball',
  nba:"Nba",
  rugby:"Rugby",
  formula1:"Formula-1",
  baseball:"Baseball",
  handball:"Handball",
  americanfootball:"American-football",
  hockey:"Hockey",
  // Add more sports and their corresponding collection names here
};
  
const hosts={
  football:"v3.football.api-sports.io",
  volleyball:"v1.volleyball.api-sports.io",
  basketball:"v1.basketball.api-sports.io",
  nba:"v2.nba.api-sports.io",
  rugby:"v1.rugby.api-sports.io",
  formula1:"v1.formula-1.api-sports.io",
  baseball:"v1.baseball.api-sports.io",
  handball:"v1.handball.api-sports.io",
  americanfootball:"v1.american-football.api-sports.io",
  hockey:"v1.hockey.api-sports.io",

}
export const scheduledFunction = functions.pubsub
.schedule('every 15 minutes')
.onRun(async (context ) => {
  try {
    let footballapi:string="d7308993bc51b1690f843f569671eb3c";
    // Iterate over each sport
    const apiDoc = await admin.firestore()
    .collection("APIS").doc('api').get();
     const data = apiDoc.data();
     if(data!=undefined){
      footballapi=data.footballapi;
     }
 
for (const sportKey in apiUrls) {
  const sport = sportKey as keyof typeof apiUrls; 
  const apiUrl = apiUrls[sport];
  const collectionName = collectionNames[sport];
  const host= hosts[sport];
  // Fetch data from the API
  // Example usage 

  const response = await axios.get(apiUrl, {
    headers: {
      'x-rapidapi-key': footballapi, // Replace with your actual API key
      'x-rapidapi-host': host, // Update host as per the sport API
    },
  });

      // Post data to Firestore collection
      await postToFirestore(collectionName, response.data.response);
    }
    console.log('Data fetched and posted successfully.');
  } catch (error) {
    console.error('Error fetching or posting data:', error);
  }
});

async function postToFirestore(collectionName: string, data: any[]) {
  const firestore = admin.firestore();
  const collectionRef = firestore.collection(collectionName);
  const querySnapshot = await collectionRef
  .orderBy('createdAt', 'desc').limit(1).get();
  const latestDoc = querySnapshot.docs[0];
  const currentDate = new Date();
  // Set the time to midnight to get the start of the current day
  currentDate.setHours(0, 0, 0, 0);

  let allMatches: any[] = [];
  let isNewDocument = true;

  const updatePromises: Promise<any>[] = [];

  if (latestDoc) {
      const latestData = latestDoc.data();
      allMatches = latestData?.matches || [];
      const date= latestData.createdAt.toDate();
      date.setHours(0,0,0,0);
      if (allMatches.length >= 2000||date.getTime() < currentDate.getTime()) {
          isNewDocument = true;
      } else {
          isNewDocument = false;
      }
  } else {
      isNewDocument = true;
  }

  const matches = await Promise.all(data.map(async (item) => {
      const matchId = generateRandomUid(28);
      return {
          'matchId': matchId,
          'match': item,
          'Timestamp': admin.firestore.Timestamp.now(),
      };
  }));

  if (isNewDocument) {
      updatePromises.push(collectionRef.add({
          matches: matches,
          createdAt: admin.firestore.Timestamp.now(),
      }));
  } else {
      updatePromises.push(latestDoc.ref.update({
          matches:matches,
   
        }));
  }

  await Promise.all(updatePromises);
}


export const scheduledFunction1 = functions.pubsub
.schedule('every 15 minutes').onRun(async (context) => {
  try {
    let newsapikey:string="pub_3520028c096d8fe7a45d4e8083ceee7b27b3a";
    // Iterate over each sport
    const apiDoc = await admin.firestore()
    .collection("APIS").doc('api').get();
     const data = apiDoc.data();
     if(data!=undefined){
      newsapikey=data.newsapikey;
     }
 
     for (const sportKey in apiUrls) {
      const sport = sportKey as keyof typeof apiUrls; 
      const collectionName = collectionNames[sport];
      console.log('Collection'+collectionName);
  const baseUrl = 'https://newsdata.io/api/1/news';  
  // Construct the URL with query parameters
 const apiUrl = `${baseUrl}?apikey=${newsapikey}&q=${collectionName}&language=en`;
  const response = await axios.get(apiUrl);
  let data:any[]=response.data.results;
  if(data){
    await postToFirestore1(`${collectionName}-news`,data);
  }else{
    await postToFirestore1(`${collectionName}-news`,data);
  }
   
    }
    console.log('Data fetched and posted successfully.'+data);
  } catch (error) {
    console.error('Error fetching or posting data:',error);
  }
});

async function postToFirestore1(collectionName: string, data: any[]) {
  const firestore = admin.firestore();
  const collectionRef = firestore.collection(collectionName);
  const querySnapshot = await collectionRef
  .orderBy('createdAt', 'desc').limit(1).get();
  const latestDoc = querySnapshot.docs[0];
  const currentDate = new Date();
  // Set the time to midnight to get the start of the current day
  currentDate.setHours(0, 0, 0, 0);

  let allMatches: any[] = [];
  let isNewDocument = true;

  const updatePromises: Promise<any>[] = [];

  if (latestDoc) {
      const latestData = latestDoc.data();
      allMatches = latestData?.matches || [];
      const date= latestData.createdAt.toDate();
      date.setHours(0,0,0,0);
      if (allMatches.length >= 2000||date.getTime() < currentDate.getTime()) {
          isNewDocument = true;
      } else {
          isNewDocument = false;
      }
  } else {
      isNewDocument = true;
  }

  const matches = await Promise.all(data.map(async (item) => {
      const matchId = generateRandomUid(28);
      return {
          'articleId': matchId,
          'article': item,
          'Timestamp': admin.firestore.Timestamp.now(),
      };
  }));

  if (isNewDocument) {
      updatePromises.push(collectionRef.add({
          news: matches,
          createdAt: admin.firestore.Timestamp.now(),
      }));
  } else {
      updatePromises.push(latestDoc.ref.update({
          news:matches,
      }));
  }

  await Promise.all(updatePromises);
}

//League comments

exports.getLeagueComments=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const docId: string | undefined = queryParams["docId"] as string;
    const year: string | 
    undefined = queryParams["year"] as string;
    if (!docId || !year) {
response.status(400).json({
   error: "docId, collectionName and subcollectionName are required" });
        return;
    }
    interface comments{
      userId: string;
      createdAt: FirebaseFirestore.Timestamp;
      comment:string;
      commentId:string;
            
  }
  const replies1: { userId: string; 
    createdAt: FirebaseFirestore.Timestamp;
    comment:string;commentId:string;}[] = [];
  const profesSnapshot = await admin.firestore()
      .collection('Leagues')
      .doc(docId)
      .collection('year')
      .doc(year)
      .collection('comments')
      .get();
  
  profesSnapshot.forEach((doc) => {
      const followingData = doc.data().comments as comments[];
      followingData.forEach((professionals) => {
          replies1.push({
              userId: professionals.userId,
              createdAt: professionals.createdAt,
              comment:professionals.comment,
              commentId:professionals.commentId,
          });
      });
  });
  const comments= await Promise.all(replies1.map( async(d)=>{
    const userData1 = await fetchUserData(d.userId);
    return{
      userId: d.userId,
      createdAt: d.createdAt,
      comment:d.comment,
      commentId:d.commentId,
      author:userData1,
    }

  }));
  response.json({comments});
  }catch(error){
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
    }});

//league comments replies

exports.getLeagueCommentsreplies=
functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const docId: string | undefined = queryParams["docId"] as string;
    const year: string | 
    undefined = queryParams["year"] as string;
    const commentId:string |undefined=queryParams["commentId"]as string;
    if (!docId || !year||!commentId) {
response.status(400).json({
   error: "docId, year and commentId are required" });
        return;
    }
    interface replies {
      userId: string;
      createdAt: FirebaseFirestore.Timestamp;
      reply:string;
      commentId:string;
      replyId:string;
            
  }
  const replies1: { userId: string; 
    createdAt: FirebaseFirestore.Timestamp;
    reply:string;commentId:string;replyId:string}[] = [];
    const profesSnapshot = await admin.firestore()
    .collection('Leagues')
    .doc(docId)
    .collection('year')
    .doc(year)
    .collection('replies')
    .get();
  
  profesSnapshot.forEach((doc) => {
      const followingData = doc.data().replies as replies[];
      followingData.forEach((professionals) => {
        if(professionals.commentId==commentId){
          replies1.push({
              userId: professionals.userId,
              createdAt: professionals.createdAt,
              reply:professionals.reply,
              commentId:professionals.commentId,
              replyId:professionals.replyId,
          });}
      });
  });
  const replies= await Promise.all(replies1.map( async(d)=>{
    const userData1 = await fetchUserData(d.userId);
    return{
      userId: d.userId,
      createdAt: d.createdAt,
      reply:d.reply,
      commentId:d.commentId,
      replyId:d.replyId,
      author:userData1,
    }

  }));
  response.json({replies});
  }catch(error){
    console.error("Error getting posts:", error);
    response.status(500).json({error: "Failed to get posts"+error});
    }});
    

  
    
    const db = admin.firestore();
    const app = express();
    
    app.use(bodyParser.json());

    exports.stopMatchesEvents = functions.pubsub.schedule('every 15 minutes').onRun(async (context) => {
      try {
        const agoraapis = await admin.firestore().collection("APIS").doc('api').get();
        const data = agoraapis.data();
    
        if (data !== undefined) {
          const agoraapi = data.agoraapi;
          const agorakey = data.agorakey;
          const agorasecret = data.agorasecret;
    
          const t = new Date();
          const today = new Date(t.getFullYear(), t.getMonth(), t.getDate(), t.getHours() - 5, t.getMinutes());
    
          const matches = await admin.firestore().collection('Matches')
            .where("state1", '==', "1")
            .where("starttime", '<', today)
            .orderBy('createdAt', 'asc')
            .get();
    
          const updatePromises = matches.docs.map(async (doc) => {
            const data = doc.data();
            const starttime = data.starttime.toDate();
    
            const durationSeconds = Math.floor((Date.now() - starttime.getTime()) / 1000);
    
            await doc.ref.update({
              state1: "0",
              state2: "0",
              duration: durationSeconds,
              message: "match stopped time limit exceeded",
              stoptime: admin.firestore.Timestamp.now()
            });
    
            const converterId = data.converterId;
            if (converterId != undefined) {
              const url = `https://api.agora.io/eu/v1/projects/${agoraapi}/rtmp-converters/${converterId}`;
    
              try {
                const response = await axios.delete(url, {
                  auth: {
                    username: agorakey,
                    password: agorasecret,
                  }
                });
    
                if (response.status === 200) {
                  console.log('RTMP Converter deleted successfully');
                } else {
                  console.error(`Failed to delete RTMP Converter. Status code: ${response.status}`);
                }
              } catch (error) {
                console.error('Error deleting RTMP Converter:', error);
              }
            }
          });
    
          const events = await admin.firestore().collection('Events')
            .where("state1", '==', "1")
            .where("starttime", '<', today)
            .orderBy('createdAt', 'asc')
            .get();
    
          const updatePromises1 = events.docs.map(async (doc) => {
            const data = doc.data();
            const starttime = data.starttime.toDate();
    
            const durationSeconds = Math.floor((Date.now() - starttime.getTime()) / 1000);
    
            await doc.ref.update({
              state1: "0",
              state2: "0",
              duration: durationSeconds,
              message: "event stopped time limit exceeded",
              stoptime: admin.firestore.Timestamp.now()
            });
    
            const converterId = data.converterId;
            if (converterId != undefined) {
              const url = `https://api.agora.io/eu/v1/projects/${agoraapi}/rtmp-converters/${converterId}`;
    
              try {
                const response = await axios.delete(url, {
                  auth: {
                    username: agorakey,
                    password: agorasecret,
                  }
                });
    
                if (response.status === 200) {
                  console.log('RTMP Converter deleted successfully');
                } else {
                  console.error(`Failed to delete RTMP Converter. Status code: ${response.status}`);
                }
              } catch (error) {
                console.error('Error deleting RTMP Converter:', error);
              }
            }
          });
          await Promise.all(updatePromises);
          await Promise.all(updatePromises1);
        }
      } catch (error) {
        console.error("error", error);
      }
    
    });
    const cors = corsLib({ origin: true });   
    
    exports.addSignInData = functions.https.onRequest((req, res) => {
      cors(req, res, async () => {
        if (req.method !== 'POST') {
          res.status(405).send('Method Not Allowed');
          return;
        }
        const data = req.body;
        if (!data || !data.collection || !data.userId || !data.location) {
          res.status(400).send('Bad Request: Missing required fields');
          return;
        }
        try {
          const docRef = await db.collection(data.collection).doc(data.userId).get();
          await docRef.ref.update({
            fcmToken: data.fcmToken,
            onlinestatus: 1,
            lastonlinetimestamp: admin.firestore.Timestamp.now(),
            devicemodel: data.location.devicemodel,
            fcmcreatedAt: admin.firestore.Timestamp.now(),
            ctimestamp: admin.firestore.Timestamp.now(),
            clongitude: data.location.longitude,
            clatitude: data.location.latitude,
          });
          const querySnapshot = await docRef.ref.collection("locations").orderBy('createdAt', 'desc').limit(1).get();
          let allNotifications: any[] = [];
          let isNewDocument = true;
          if (!querySnapshot.empty) {
            const latestDoc = querySnapshot.docs[0];
            const latestData = latestDoc.data();
            allNotifications = latestData?.location || [];
            if (allNotifications.length < 4000) {
              isNewDocument = false;
            }
          }
          const location = {
            ...data.location,
            'timestamp': admin.firestore.Timestamp.now(),
          };
          if (isNewDocument) {
            await docRef.ref.collection('locations').add({
              location: [location],
              createdAt: admin.firestore.Timestamp.now(),
            });
          } else {
            const latestDoc = querySnapshot.docs[0];
            await latestDoc.ref.update({
              location: [...allNotifications, location],
            });
          }
          res.status(200).send('200');
        } catch (error) {
          console.error('Error adding data:', error);
          res.status(500).send('Internal Server Error');
        }
      });
    });
    



exports.addSignOutData = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }
    const data = req.body;
    if (!data || !data.collection || !data.userId) {
      res.status(400).send('Bad Request: Missing required fields');
      return;
    }
    try {
      const docRef = await db.collection(data.collection).doc(data.userId).get();
      await docRef.ref.update({
        fcmToken: "",
        onlinestatus: 0,
        lastonlinetimestamp: admin.firestore.Timestamp.now(),
      });
      res.status(200).send(`200`);
    } catch (error) {
      console.error('Error adding data:', error);
      res.status(500).send('Internal Server Error');
    }
  });
});



interface alldata {
  collection: string,
  docId: string,
  subcollection: string,
  subdocId: string,
  data: any,
}

const allDataList: alldata[] = [];

exports.addData = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    const data = req.body;
    if (!data || !data.collection || !data.docId || !data.subcollection || !data.data) {
      res.status(400).send('Bad Request: Missing required fields');
      return;
    }
    try {
      allDataList.push({
        collection: data.collection,
        docId: data.docId,
        subcollection: data.subcollection,
        subdocId: data.subdocId,
        data: data.data,
      });
      console.log('Data added to allDataList:', allDataList);
      if (allDataList.length>0) {
        await processPostData();
      }
      res.status(200).send('200');
    } catch (error) {
      console.error('Error adding data:', error);
      res.status(500).send('Internal Server Error');
    }
  });
});

exports.processaddData = functions.pubsub.schedule('every 1 minutes').onRun(async () => {
  await processPostData();
});

async function processPostData() {
  if (allDataList.length === 0) {
    console.log('Queue is empty. No data to process.');
    return;
  }

  try {
    while (allDataList.length > 0) {
      const item = allDataList.shift();
      console.log('Processing item:', item);

      if (item) {
        const querySnapshot = await admin.firestore().collection(item.collection).doc(item.docId)
          .collection(item.subcollection).orderBy('createdAt', 'desc').limit(1).get();

        let notifications = [];
        let data;
        let createdAt;
        let latestDoc: admin.firestore.DocumentSnapshot<admin.firestore.DocumentData> | undefined;
        let isNewDocument = true;
        let subcollection = item.subcollection;

        if (item.subcollection === 'comments' || item.subcollection === 'replies') {
          data = {
            ...item.data,
            createdAt: admin.firestore.Timestamp.now(),
          };
        } else {
          data = {
            ...item.data,
            timestamp: admin.firestore.Timestamp.now(),
          };
        }

        if (!querySnapshot.empty) {
          latestDoc = querySnapshot.docs[0];
          const docData = latestDoc.data();
          if (docData) {
            createdAt = docData.createdAt;
            if (item.subcollection === 'chat') {
              subcollection = "chats";
              notifications = docData.chats || [];
            } else {
              notifications = docData[item.subcollection] || [];
            }
            // Check for empty strings in the notifications array
            notifications = notifications.filter((notification: any) => notification !== "");
            if (notifications.length < 3000) {
              isNewDocument = false;
            }
          }
        }
        if (isNewDocument) {
          console.log('Creating new document for:', item.subcollection);
          await admin.firestore().collection(item.collection).doc(item.docId)
            .collection(item.subcollection).add({
              [subcollection]: [data],
              createdAt: admin.firestore.Timestamp.now(),
            });
        } else if (latestDoc) { // Ensure latestDoc is defined before updating
          // Prepare the update data
          const updateData: { [key: string]: any } = {
            [subcollection]: [...notifications, data],
          };
          // Ensure 'createdAt' field exists in the existing document
          if (!createdAt) {
            updateData.createdAt = admin.firestore.Timestamp.now();
          }
          console.log('Updating existing document for:', item.subcollection);
          await latestDoc.ref.update(updateData);
        }
      }
    }
    console.log('Data processing complete.');
  } catch (error) {
    console.error('Error processing data:', error);
  }
}



interface LikeData {
  userId: string;
  timestamp: admin.firestore.Timestamp;
}
interface ViewData {
  userId: string;
  timestamp: admin.firestore.Timestamp;
  watchhours: number;
}
interface LikesDataPoint {
  minute: number;
  likes: number;
}
interface ViewsDataPoint {
  minute: number;
  views: number;
  watchhours:number;
}
interface DonationData {
  transactionId: string;
  amount:number;
  timestamp: admin.firestore.Timestamp;
}
interface DonationsDataPoint {
  minute: number;
  amount: number;
}
exports.matchData = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const docId: string | undefined = queryParams['docId'] as string;
    const collection: string | undefined = queryParams['collection'] as string;

    if (!docId || !collection) {
      response.status(400).send('Missing query parameters: docId and collection are required.');
      return;
    }

    // Retrieve the match document
    const matchDoc = await admin.firestore()
      .collection(collection)
      .doc(docId)
      .get();

    if (!matchDoc.exists) {
      response.status(404).send('Match document not found');
      return;
    }

    const matchData = matchDoc.data();
    if (!matchData) {
      response.status(404).send('No match data found');
      return;
    }

    const matchStartTime = matchData.starttime.toDate();
    const matchStopTime = matchData.stoptime.toDate();
    const totalMinutes = Math.ceil((matchStopTime.getTime() - matchStartTime.getTime()) / 1000 / 60);

    // Retrieve the match likes from Firestore
    const matchLikesSnapshot = await admin.firestore()
      .collection(collection)
      .doc(docId)
      .collection('likes')
      .get();

    const matchViewsSnapshot = await admin.firestore()
      .collection(collection)
      .doc(docId)
      .collection('views')
      .get();
      const matchDonationsSnapshot = await admin.firestore()
      .collection(collection)
      .doc(docId)
      .collection('donations')
      .get();
    const matchLikes: LikeData[] = [];
    matchLikesSnapshot.forEach((doc) => {
      const likesList = doc.data().likes as LikeData[];
      likesList.forEach((like) => {
        matchLikes.push({
          userId: like.userId,
          timestamp: like.timestamp
        });
      });
    });

    const matchViews: ViewData[] = [];
    matchViewsSnapshot.forEach((doc) => {
      const viewsList = doc.data().views as ViewData[];
      viewsList.forEach((view) => {
        matchViews.push({
          userId: view.userId,
          timestamp: view.timestamp,
          watchhours: view.watchhours
        });
      });
    });
    const matchDonations: DonationData[] = [];
    matchDonationsSnapshot.forEach((doc) => {
      const viewsList = doc.data().views as DonationData[];
      viewsList.forEach((view) => {
        matchDonations.push({
          transactionId: view.transactionId,
          timestamp: view.timestamp,
          amount: view.amount,
        });
      });
    });
    // Initialize arrays to count likes and views per minute for the duration of the match
    const likesPerMinute: number[] = Array(totalMinutes).fill(0);
    const viewsPerMinute: number[] = Array(totalMinutes).fill(0);
    const watchhoursPerMinute: number[] = Array(totalMinutes).fill(0);
    const DonationsPerMinute: number[] = Array(totalMinutes).fill(0);
    const AmountPerMinute: number[] = Array(totalMinutes).fill(0);
    // Calculate likes and views per minute
    matchLikes.forEach(like => {
      const likeTimestamp = like.timestamp.toDate();
      const difference = (likeTimestamp.getTime() - matchStartTime.getTime()) / 1000 / 60;
      const minute = Math.floor(difference);

      // Ensure the minute is within the total match duration
      if (minute >= 0 && minute < totalMinutes) {
        likesPerMinute[minute]++;
      }
    });

    matchViews.forEach(view => {
      const viewTimestamp = view.timestamp.toDate();
      const difference = (viewTimestamp.getTime() - matchStartTime.getTime()) / 1000 / 60;
      const minute = Math.floor(difference);
      const watchhour = view.watchhours;

      // Ensure the minute is within the total match duration
      if (minute >= 0 && minute < totalMinutes) {
        viewsPerMinute[minute]++;
        watchhoursPerMinute[minute] += watchhour;
      }
    });

    matchDonations.forEach(view => {
      const viewTimestamp = view.timestamp.toDate();
      const difference = (viewTimestamp.getTime() - matchStartTime.getTime()) / 1000 / 60;
      const minute = Math.floor(difference);
      const amount = view.amount;

      // Ensure the minute is within the total match duration
      if (minute >= 0 && minute < totalMinutes) {
        DonationsPerMinute[minute]++;
        AmountPerMinute[minute] += amount;
      }
    });
    // Create the likesDatapoints and viewsDatapoints lists with minute, likes, and views data
    const likesDatapoints: LikesDataPoint[] = likesPerMinute.map((likes, index) => ({
      minute: index + 1,
      likes: likes
    }));
    const viewsDatapoints: ViewsDataPoint[] = viewsPerMinute.map((views, index) => ({
      minute: index + 1,
      views: views,
      watchhours: watchhoursPerMinute[index]
    }));
    const donationsDatapoints: DonationsDataPoint[] = DonationsPerMinute.map((views, index) => ({
      minute: index + 1,
      amount: AmountPerMinute[index]
    }));
    const dataPoints = {
      likesDatapoints,
      viewsDatapoints,
      donationsDatapoints,
    };
    response.status(200).json({dataPoints:dataPoints});
  } catch (error) {
    console.error('Error retrieving match data:', error);
    response.status(500).send(`Error retrieving match data: ${error}`);
  }
});

interface FollowersDataPoint {
  date: string;
  users: number;
}


exports.userData = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string, string | string[] | undefined> = convertParsedQs(request.query);
    const docId: string | undefined = queryParams['docId'] as string;
    const collection: string | undefined = queryParams['collection'] as string;
    const subcollection: string | undefined = queryParams['subcollection'] as string;
    const from: string | undefined = queryParams['from'] as string;
    const to: string | undefined = queryParams['to'] as string;

    if (!docId || !collection || !subcollection || !from || !to) {
      response.status(400).send('Missing query parameters: docId, collection, subcollection, from, and to are required.');
      return;
    }

    // Convert from and to dates from string to Date object
    const fromDate = new Date(from);
    const toDate = new Date(to);

    if (isNaN(fromDate.getTime()) || isNaN(toDate.getTime())) {
      response.status(400).send('Invalid date format for from or to.');
      return;
    }

    // Retrieve the match likes from Firestore
    const matchLikesSnapshot = await admin.firestore()
      .collection(collection)
      .doc(docId)
      .collection(subcollection)
      .get();

    const users: LikeData[] = [];
    matchLikesSnapshot.forEach((doc) => {
      const data = doc.data();
      const likesList = data[subcollection] as LikeData[];
      likesList.forEach((like) => {
        users.push({
          userId: like.userId,
          timestamp: like.timestamp
        });
      });
    });

    // Initialize arrays to count likes per day
    const followersPerDay: Record<string, number> = {};

    // Calculate likes per day within the date range
    users.forEach(like => {
      const likeTimestamp = like.timestamp.toDate();
      if (likeTimestamp >= fromDate && likeTimestamp <= toDate) {
        const dateKey = likeTimestamp.toISOString().split('T')[0]; // Format date as 'YYYY-MM-DD'
        if (!followersPerDay[dateKey]) {
          followersPerDay[dateKey] = 0;
        }
        followersPerDay[dateKey]++;
      }
    });

    // Convert followersPerDay object to an array of FollowersDataPoint
    const followersDatapoints: FollowersDataPoint[] = Object.keys(followersPerDay).map(date => ({
      date: date,
      users: followersPerDay[date]
    }));

    
    response.status(200).json({followersDatapoints});
  } catch (error) {
    console.error('Error retrieving user data:', error);
    response.status(500).send(`Error retrieving user data: ${error}`);
  }
});

async function getExchangeRates(): Promise<{ [key: string]: number } | void> {
  try {
    const agoraapis = await db.collection("APIS").doc('api').get();
    const data = agoraapis.data();
    if (data) {
      const APIKEY = data.exchangeRateApi;
      const url = `https://v6.exchangerate-api.com/v6/${APIKEY}/latest/USD`;
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      const apiData = await response.json();
      return apiData.conversion_rates;
    }
  } catch (error) {
    console.error('Fetch error:', error);
    throw error;
  }
}

async function updateExchangeRates(): Promise<void> {
  const exchangeRates = await getExchangeRates();
  if (exchangeRates) {
    const countryData = getCountryData();
    await db.collection('exchangeRates').doc('USD').set({
      ...exchangeRates,
      timestamp: admin.firestore.Timestamp.now(),
      countryData:countryData,
    });
  }
}
interface CountryData {
  country: string;
  currency: string;
}


const getCountryData = (): CountryData[] => {
  return [
    { country: "United Arab Emirates", currency: "AED" },
    { country: "Afghanistan", currency: "AFN" },
    { country: "Albania", currency: "ALL" },
    { country: "Armenia", currency: "AMD" },
    { country: "Aruba", currency: "AWG" },
    { country: "Angola", currency: "AOA" },
    { country: "Argentina", currency: "ARS" },
    { country: "Australia", currency: "AUD" },
    { country: "Azerbaijan", currency: "AZN" },
    { country: "Bosnia and Herzegovina", currency: "BAM" },
    { country: "Barbados", currency: "BBD" },
    { country: "Bangladesh", currency: "BDT" },
    { country: "Bulgaria", currency: "BGN" },
    { country: "Bahrain", currency: "BHD" },
    { country: "Burundi", currency: "BIF" },
    { country: "Bermuda", currency: "BMD" },
    { country: "Brunei", currency: "BND" },
    { country: "Bolivia", currency: "BOB" },
    { country: "Brazil", currency: "BRL" },
    { country: "Bahamas", currency: "BSD" },
    { country: "Bhutan", currency: "BTN" },
    { country: "Botswana", currency: "BWP" },
    { country: "Belarus", currency: "BYN" },
    { country: "Belize", currency: "BZD" },
    { country: "Canada", currency: "CAD" },
    { country: "Democratic Republic of the Congo", currency: "CDF" },
    { country: "Switzerland", currency: "CHF" },
    { country: "Chile", currency: "CLP" },
    { country: "China", currency: "CNY" },
    { country: "Colombia", currency: "COP" },
    { country: "Costa Rica", currency: "CRC" },
    { country: "Cuba", currency: "CUP" },
    { country: "Cape Verde", currency: "CVE" },
    { country: "Czech Republic", currency: "CZK" },
    { country: "Djibouti", currency: "DJF" },
    { country: "Denmark", currency: "DKK" },
    { country: "Dominican Republic", currency: "DOP" },
    { country: "Algeria", currency: "DZD" },
    { country: "Egypt", currency: "EGP" },
    { country: "Eritrea", currency: "ERN" },
    { country: "Ethiopia", currency: "ETB" },
    { country: "Eurozone", currency: "EUR" },
    { country: "Fiji", currency: "FJD" },
    { country: "Falkland Islands", currency: "FKP" },
    { country: "Faroe Islands", currency: "FOK" },
    { country: "United Kingdom", currency: "GBP" },
    { country: "Georgia", currency: "GEL" },
    { country: "Guernsey", currency: "GGP" },
    { country: "Ghana", currency: "GHS" },
    { country: "Gibraltar", currency: "GIP" },
    { country: "Gambia", currency: "GMD" },
    { country: "Guinea", currency: "GNF" },
    { country: "Guatemala", currency: "GTQ" },
    { country: "Guyana", currency: "GYD" },
    { country: "Hong Kong", currency: "HKD" },
    { country: "Honduras", currency: "HNL" },
    { country: "Croatia", currency: "HRK" },
    { country: "Haiti", currency: "HTG" },
    { country: "Hungary", currency: "HUF" },
    { country: "Indonesia", currency: "IDR" },
    { country: "Israel", currency: "ILS" },
    { country: "Isle of Man", currency: "IMP" },
    { country: "India", currency: "INR" },
    { country: "Iraq", currency: "IQD" },
    { country: "Iran", currency: "IRR" },
    { country: "Iceland", currency: "ISK" },
    { country: "Jersey", currency: "JEP" },
    { country: "Jamaica", currency: "JMD" },
    { country: "Jordan", currency: "JOD" },
    { country: "Japan", currency: "JPY" },
    { country: "Kenya", currency: "KES" },
    { country: "Kyrgyzstan", currency: "KGS" },
    { country: "Cambodia", currency: "KHR" },
    { country: "Kiribati", currency: "KID" },
    { country: "Comoros", currency: "KMF" },
    { country: "South Korea", currency: "KRW" },
    { country: "Kuwait", currency: "KWD" },
    { country: "Cayman Islands", currency: "KYD" },
    { country: "Kazakhstan", currency: "KZT" },
    { country: "Laos", currency: "LAK" },
    { country: "Lebanon", currency: "LBP" },
    { country: "Sri Lanka", currency: "LKR" },
    { country: "Liberia", currency: "LRD" },
    { country: "Lesotho", currency: "LSL" },
    { country: "Libya", currency: "LYD" },
    { country: "Morocco", currency: "MAD" },
    { country: "Moldova", currency: "MDL" },
    { country: "Madagascar", currency: "MGA" },
    { country: "North Macedonia", currency: "MKD" },
    { country: "Myanmar", currency: "MMK" },
    { country: "Mongolia", currency: "MNT" },
    { country: "Macau", currency: "MOP" },
    { country: "Mauritania", currency: "MRU" },
    { country: "Mauritius", currency: "MUR" },
    { country: "Maldives", currency: "MVR" },
    { country: "Malawi", currency: "MWK" },
    { country: "Mexico", currency: "MXN" },
    { country: "Malaysia", currency: "MYR" },
    { country: "Mozambique", currency: "MZN" },
    { country: "Namibia", currency: "NAD" },
    { country: "Nigeria", currency: "NGN" },
    { country: "Nicaragua", currency: "NIO" },
    { country: "Norway", currency: "NOK" },
    { country: "Nepal", currency: "NPR" },
    { country: "New Zealand", currency: "NZD" },
    { country: "Oman", currency: "OMR" },
    { country: "Panama", currency: "PAB" },
    { country: "Peru", currency: "PEN" },
    { country: "Papua New Guinea", currency: "PGK" },
    { country: "Philippines", currency: "PHP" },
    { country: "Pakistan", currency: "PKR" },
    { country: "Poland", currency: "PLN" },
    { country: "Paraguay", currency: "PYG" },
    { country: "Qatar", currency: "QAR" },
    { country: "Romania", currency: "RON" },
    { country: "Serbia", currency: "RSD" },
    { country: "Russia", currency: "RUB" },
    { country: "Rwanda", currency: "RWF" },
    { country: "Saudi Arabia", currency: "SAR" },
    { country: "Solomon Islands", currency: "SBD" },
    { country: "Seychelles", currency: "SCR" },
    { country: "Sudan", currency: "SDG" },
    { country: "Sweden", currency: "SEK" },
    { country: "Singapore", currency: "SGD" },
    { country: "Saint Helena", currency: "SHP" },
    { country: "Sierra Leone", currency: "SLL" },
    { country: "Somalia", currency: "SOS" },
    { country: "Suriname", currency: "SRD" },
    { country: "South Sudan", currency: "SSP" },
    { country: "São Tomé and Príncipe", currency: "STN" },
    { country: "Syria", currency: "SYP" },
    { country: "Eswatini", currency: "SZL" },
    { country: "Thailand", currency: "THB" },
    { country: "Tajikistan", currency: "TJS" },
    { country: "Turkmenistan", currency: "TMT" },
    { country: "Tunisia", currency: "TND" },
    { country: "Tonga", currency: "TOP" },
    { country: "Turkey", currency: "TRY" },
    { country: "Trinidad and Tobago", currency: "TTD" },
    { country: "Tuvalu", currency: "TVD" },
    { country: "Taiwan", currency: "TWD" },
    { country: "Tanzania", currency: "TZS" },
    { country: "Ukraine", currency: "UAH" },
    { country: "Uganda", currency: "UGX" },
    { country: "United States", currency: "USD" },
    { country: "Uruguay", currency: "UYU" },
    { country: "Uzbekistan", currency: "UZS" },
    { country: "Venezuela", currency: "VES" },
    { country: "Vietnam", currency: "VND" },
    { country: "Vanuatu", currency: "VUV" },
    { country: "Samoa", currency: "WST" },
    { country: "Central African Republic", currency: "XAF" },
    { country: "East Caribbean", currency: "XCD" },
    { country: "International Monetary Fund", currency: "XDR" },
    { country: "West African States", currency: "XOF" },
    { country: "French Polynesia", currency: "XPF" },
    { country: "Yemen", currency: "YER" },
    { country: "South Africa", currency: "ZAR" },
    { country: "Zambia", currency: "ZMW" },
    { country: "Zimbabwe", currency: "ZWL" }
  ];
};


exports.scheduledUpdateExchangeRates = functions.pubsub.schedule('every 12 hours').onRun(async (context) => {
  await updateExchangeRates();
  console.log('Exchange rates updated successfully.');
});



interface MatchData {
  date: string;
  starttime: FirebaseFirestore.Timestamp;
  stoptime: FirebaseFirestore.Timestamp;
  scheduledDate: string;
  matchId: string;
  day: number;
  totalLikes: number;
  duration: number;
  totalWatchhours: number;
  totalViews: number;
  donations:number;
  amount: number;
}

exports.allMatchData = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string, string | string[] | undefined> = convertParsedQs(request.query);
    const authorId: string | undefined = queryParams['docId'] as string;
    const collection: string | undefined = queryParams['collection'] as string;

    if (!authorId || !collection) {
      response.status(400).send('Missing query parameters: authorId and collection are required.');
      return;
    }

    // Determine the start of the current month and today's date
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0); // Last day of the current month

    // Query matches within the current month
    const matchesSnapshot = await admin.firestore()
      .collection(collection)
      .where('authorId', '==', authorId)
      .where('stoptime', '>=', startOfMonth)
      .where('stoptime', '<=', endOfMonth)
      .get();

    const matchDataList: MatchData[] = [];

    for (const matchDoc of matchesSnapshot.docs) {
      const matchId = matchDoc.id;
      const matchData = matchDoc.data();
      const starttime = matchData.starttime.toDate();
      const stoptime = matchData.stoptime.toDate();
      const scheduledDate = matchData.scheduledDate;
      const totalMinutes = Math.ceil((stoptime.getTime() - starttime.getTime()) / 1000 / 60);

      // Initialize totals
      let totalLikes = 0;
      let totalViews = 0;
      let totalWatchhours = 0;
      let totalDonations = 0;
      let amount = 0;
      // Retrieve likes and views for the current match
      const matchLikesSnapshot = await admin.firestore()
        .collection(collection)
        .doc(matchId)
        .collection('likes')
        .get();

      const matchViewsSnapshot = await admin.firestore()
        .collection(collection)
        .doc(matchId)
        .collection('views')
        .get();
        const matchDonationsSnapshot = await admin.firestore()
        .collection(collection)
        .doc(matchId)
        .collection('views')
        .get();
      // Aggregate likes
      matchLikesSnapshot.forEach((doc) => {
        const likesList = doc.data().likes as LikeData[];
        totalLikes += likesList.length;
      });

      // Aggregate views and watch hours
      matchViewsSnapshot.forEach((doc) => {
        const viewsList = doc.data().views as ViewData[];
        totalViews += viewsList.length;
        totalWatchhours += viewsList.reduce((sum, view) => sum + view.watchhours, 0);
      });
      matchDonationsSnapshot.forEach((doc) => {
        const viewsList = doc.data().views as DonationData[];
        totalDonations += viewsList.length;
        amount += viewsList.reduce((sum, view) => sum + view.amount, 0);
      });
      // Calculate the day of the month
      const day = starttime.getDate();

      // Create the match data object
      const matchDataPoint: MatchData = {
        date: starttime.toISOString().split('T')[0], // Format date as YYYY-MM-DD
        starttime: matchData.starttime,
        stoptime: matchData.stoptime,
        scheduledDate: scheduledDate,
        matchId: matchId,
        day: day,
        totalLikes: totalLikes,
        duration: totalMinutes,
        totalWatchhours: totalWatchhours,
        totalViews: totalViews,
        donations:totalDonations,
        amount: amount,
      };

      // Add to the list
      matchDataList.push(matchDataPoint);
    }

    response.status(200).json({ matchDataPoints: matchDataList });
  } catch (error) {
    console.error('Error retrieving match data:', error);
    response.status(500).send(`Error retrieving match data: ${error}`);
  }
});

// Function to handle the transaction
 exports.handleTransaction = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (req, response) => {
  const transactionData = req.body;
  try {
 const id=generateRandomUid(28);
    // Save the transaction result to Firestore
    await db.collection('Transactions').doc(id).set({
      transactionId:id,
      transaction: transactionData,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    response.status(200).json(200);
  } catch (error) {
    console.error('Error retrieving match data:', error);
    response.status(500).send(`Error retrieving match data: ${error}`);
  }
});

exports.postData = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (request, response) => {
  try {
    const queryParams: Record<string,
    string | string[] | undefined> = convertParsedQs(request.query);
    const docId: string | undefined = queryParams['docId'] as string;
    const collection: string | undefined = queryParams['collection'] as string;

    if (!docId || !collection) {
      response.status(400).send('Missing query parameters: docId and collection are required.');
      return;
    }
    // Retrieve the match document
    const matchDoc = await admin.firestore()
      .collection(collection)
      .doc(docId)
      .get();
    if (!matchDoc.exists) {
      response.status(404).send('Match document not found');
      return;
    }
    const matchData = matchDoc.data();
    if (!matchData) {
      response.status(404).send('No match data found');
      return;
    }
    const matchStartTime = matchData.createdAt.toDate();
    const matchStopTime = new Date();
    const totalDays = Math.ceil((matchStopTime.getTime() - matchStartTime.getTime()) / 1000 / 60/60/24);
    // Retrieve the match likes from Firestore
    const matchLikesSnapshot = await admin.firestore()
      .collection(collection)
      .doc(docId)
      .collection('likes')
      .get();
    const matchViewsSnapshot = await admin.firestore()
      .collection(collection)
      .doc(docId)
      .collection('views')
      .get();

    const matchLikes: LikeData[] = [];
    matchLikesSnapshot.forEach((doc) => {
      const likesList = doc.data().likes as LikeData[];
      likesList.forEach((like) => {
        matchLikes.push({
          userId: like.userId,
          timestamp: like.timestamp
        });
      });
    });

    const matchViews: ViewData[] = [];
    matchViewsSnapshot.forEach((doc) => {
      const viewsList = doc.data().views as ViewData[];
      viewsList.forEach((view) => {
        matchViews.push({
          userId: view.userId,
          timestamp: view.timestamp,
          watchhours: view.watchhours
        });
      });
    });
    // Initialize arrays to count likes and views per minute for the duration of the match
    const likesPerDay: number[] = Array(totalDays).fill(0);
    const viewsPerDay: number[] = Array(totalDays).fill(0);
    const watchhoursPerMinute: number[] = Array(totalDays).fill(0);
    // Calculate likes and views per minute
    matchLikes.forEach(like => {
      const likeTimestamp = like.timestamp.toDate();
      const difference = (likeTimestamp.getTime() - matchStartTime.getTime()) / 1000 / 60 / 60 / 24;
      const day = Math.floor(difference);

      // Ensure the minute is within the total match duration
      if (day >= 0 && day < totalDays) {
        likesPerDay[day]++;
      }
    });

    matchViews.forEach(view => {
      const viewTimestamp = view.timestamp.toDate();
      const difference = (viewTimestamp.getTime() - matchStartTime.getTime()) / 1000 / 60/ 60 / 24;
      const day = Math.floor(difference);
      const watchhour = view.watchhours;
      // Ensure the minute is within the total match duration
      if (day >= 0 && day < totalDays) {
        viewsPerDay[day]++;
        watchhoursPerMinute[day] += watchhour;
      }
    });
    // Create the likesDatapoints and viewsDatapoints lists with minute, likes, and views data
    const likesDatapoints: LikesDataPoint[] = likesPerDay.map((likes, index) => ({
      minute: index + 1,
      likes: likes
    }));
    const viewsDatapoints: ViewsDataPoint[] = viewsPerDay.map((views, index) => ({
      minute: index + 1,
      views: views,
      watchhours: watchhoursPerMinute[index]
    }));
    const dataPoints = {
      likesDatapoints,
      viewsDatapoints
    };
    response.status(200).json({dataPoints:dataPoints});
  } catch (error) {
    console.error('Error retrieving match data:', error);
    response.status(500).send(`Error retrieving match data: ${error}`);
  }
});

exports.handleDonationTransaction = functions.runWith({
  timeoutSeconds: 540 // Adjust the timeout value as needed
}).https.onRequest(async (req, res) => {
  const queryParams: Record<string,
  string | string[] | undefined> = convertParsedQs(req.query);
  const docId: string | undefined = queryParams['docId'] as string;
  const collection: string | undefined = queryParams['collection'] as string;
  const userId: string | undefined = queryParams['userId'] as string;
  const authorId: string | undefined = queryParams['authorId'] as string;
  if (!docId || !collection) {
    res.status(400).send('Missing required query parameters: docId or collection');
    return;
  }

  try {
    const id = generateRandomUid(28);
    const transactionData = req.body.Body.stkCallback;
    if (!transactionData || !transactionData.CallbackMetadata || !userId) {
      res.status(400).send('Invalid transaction data or missing userId');
      return;
    }

    const items = transactionData.CallbackMetadata.Item;
    const amountItem = items.find((item: any) => item.Name === 'Amount');
    //const mpesaReceiptNumber = items.find((item: any) => item.Name === 'MpesaReceiptNumber')?.Value;
    //const transactionDate = items.find((item: any) => item.Name === 'TransactionDate')?.Value;

    if (!amountItem || !amountItem.Value) {
      res.status(400).send('Amount not found in transaction data');
      return;
    }
    let country:string="";
    const userData=await fetchUserData(authorId);
          if(userData.country){
            country=userData.country;
          }
    const amount = amountItem.Value;
    const amountInUsd = await convertToUSD(amount, country); // Assuming 'KES' is the currency code for Kenyan Shilling
    const newDonation = {
      transactionId: id,
      amountInUsd: amountInUsd,
      userId: userId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Save the transaction result to Firestore
    await db.collection('Transactions').doc(id).set({
      transactionId: id,
      transaction: transactionData,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    const querySnapshot = await db.collection(collection).doc(docId)
      .collection("donations").orderBy('createdAt', 'desc').limit(1).get();

    let donations: any[] = [];
    let createdAt: admin.firestore.Timestamp | undefined;
    let latestDoc: admin.firestore.DocumentSnapshot | undefined;
    let isNewDocument = true;

    if (!querySnapshot.empty) {
      latestDoc = querySnapshot.docs[0];
      const docData = latestDoc.data();
      if (docData) {
        createdAt = docData.createdAt;
        donations = docData["donations"] || [];
      }
      donations = donations.filter((donation: any) => donation !== "");
      if (donations.length < 3000) {
        isNewDocument = false;
      }
    }

    if (isNewDocument) {
      console.log('Creating new document for donations');
      await db.collection(collection).doc(docId).collection('donations').add({
        donations: [newDonation],
        createdAt: admin.firestore.Timestamp.now(),
      });
    } else if (latestDoc) {
      const updateData: { [key: string]: any } = {
        donations: [...donations, newDonation],
      };
      if (!createdAt) {
        updateData.createdAt = admin.firestore.Timestamp.now();
      }
      console.log('Updating existing document for donations');
      await latestDoc.ref.update(updateData);
    }

    res.status(200).json({ status: 'success', transactionId: id });
  } catch (error) {
    console.error('Error handling donation transaction:', error);
    res.status(500).send(`Error handling donation transaction: ${error}`);
  }
});

async function convertToUSD(amount: number, country: string): Promise<number> {
  // Fetch exchange rates from Firestore
  const exchangeRatesDoc = await admin.firestore().collection('exchangeRates').doc('USD').get();
  const exchangeRates = exchangeRatesDoc.data();
  const countryData = exchangeRates?.countryData || [];

  if (!exchangeRates) {
    throw new Error('Exchange rates not found');
  }

  // Find the currency for the given country
  const countryInfo = countryData.find((d: { country: string }) => d.country === country);
  
  if (!countryInfo) {
    throw new Error(`Currency for country ${country} not found`);
  }

  const currency = countryInfo.currency;
  const rate = exchangeRates[currency];

  if (!rate) {
    throw new Error(`Exchange rate for ${currency} not found`);
  }

  // Convert the amount to USD
  const amountInUSD = amount / rate;

  return amountInUSD;
}

// Example usage
convertToUSD(100, 'Kenya').then(amountInUSD => {
  console.log('Amount in USD:', amountInUSD);
}).catch(error => {
  console.error('Error:', error);
});
