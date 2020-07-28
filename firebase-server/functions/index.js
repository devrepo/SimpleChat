const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp();
const firestore = admin.firestore();

/**
 * exports.sendMessage = functions.https.onRequest(async (req, res) => {
    const { sender, message, time, seen, recipient } = JSON.parse(req.body);
    const collectionRef = firestore.collection('messages');
    const writeResult = await collectionRef.add({message, user: sender, time, seen, recipient});
    res.json({result: {
        success: true,
        error: null,
        id: writeResult.id
    }});
})


exports.readMessages = functions.https.onRequest( async (req, res) => {
    const { recipient } = JSON.parse(req.body);
    const collectionRef = firestore.collection('messages');
    const docRefs = [];
    await collectionRef.where('recipient', "==", recipient).get().then(querySnapshot => {
        const docs = querySnapshot.docs;
        for (let doc of docs) {
            const data = doc.data();
            docRefs.push({...data, id: doc.id});
        }
    })
    res.json({
        result: {
            success : true,
            error: null,
            messages : docRefs
        }
    })
})

exports.markAsSeen = functions.https.onRequest( async (req, res) => {
    const { id } = JSON.parse(req.body);
    const collectionRef = firestore.collection('messages');
    let query = collectionRef.doc(id);
    await query.get().then(queryDocumentSnapshot => {
        queryDocumentSnapshot.ref.set( { seen: true, time: new Date()}, {merge : true});
    })
    res.json({
        result: {
            success : true,
            error: null
        }
    })
})
*/
exports.createRoom = functions.https.onRequest( async (req, res) => {
    let parsedBody;
    try{
        parsedBody = JSON.parse(req.body);
    } catch (e){
        if (e instanceof SyntaxError) {
            parsedBody = req.body;
        }
    }
    const { room, userId } = parsedBody;
    const collectionRef = firestore.collection('rooms');
    const writeResult = await collectionRef.add({room: room, members: [ userId ]});
    res.json({result: {
        success: true,
        error: null,
        roomId: writeResult.id
    }});
});

exports.joinRoom = functions.https.onRequest( async (req, res) => {
    let parsedBody;
    try{
        parsedBody = JSON.parse(req.body);
    } catch (e){
        if (e instanceof SyntaxError) {
            parsedBody = req.body;
        }
    }
    const { roomId, userId } = parsedBody;
    const collectionRef = firestore.collection('rooms');
    let query = collectionRef.doc(roomId);
    await query.get().then(queryDocumentSnapshot => {
        if (queryDocumentSnapshot.exists){
            const { members } = queryDocumentSnapshot.data();
            members.push(userId)
            queryDocumentSnapshot.ref.set( { members: members }, {merge : true});
        }
        return null;
    })
    res.json({result: {
        success: true,
        error: null
    }});
});

exports.getMyRooms = functions.https.onRequest( async (req, res) => {
    let parsedBody;
    try{
        parsedBody = JSON.parse(req.body);
    } catch (e){
        if (e instanceof SyntaxError) {
            parsedBody = req.body;
        }
    }
    const { userId } = parsedBody;
    const collectionRef = firestore.collection('rooms');
    const docRefs = [];
    await collectionRef.where('members', "array-contains", userId).get().then(querySnapshot => {
        const docs = querySnapshot.docs;
        for (let doc of docs) {
            const data = doc.data();
            data.id = doc.id;
            docRefs.push(data);
        }
        return null;
    })
    res.json({
        result: {
            success : true,
            error: null,
            rooms : docRefs
        }
    })
});

exports.getAllRooms = functions.https.onRequest( async (req, res) => {
    const collectionRef = firestore.collection('rooms');
    const docRefs = [];
    await collectionRef.get().then(querySnapshot => {
        const docs = querySnapshot.docs;
        for (let doc of docs) {
            const data = doc.data();
            data.id = doc.id;
            docRefs.push(data);
        }
        return null;
    })
    res.json({
        result: {
            success : true,
            error: null,
            rooms : docRefs
        }
    })
});

exports.sendMessage = functions.https.onRequest(async (req, res) => {
    let parsedBody;
    try{
        parsedBody = JSON.parse(req.body);
    } catch (e){
        if (e instanceof SyntaxError) {
            parsedBody = req.body;
        }
    }
    const { sender, message, time, seen, roomId } = parsedBody;
    functions.logger.info("Hello logs!", sender);
    const documentRef = firestore.collection('rooms').doc(roomId);
    let result = {
        success: false,
        error: "Room not found"
    };
    let writeResult;
    const queryDocumentSnapshot = await documentRef.get();
    if (queryDocumentSnapshot.exists){
        result.success = true;
        result.error = null;
        functions.logger.info("Document found", sender);
        const collectionRef = documentRef.collection('messages');
        writeResult = await collectionRef.add({message: message, user: sender, time:time, seen:seen});
    }

    if (writeResult){
        result.id = writeResult.id;
    }
    res.json({result});
});

exports.readMessages = functions.https.onRequest( async (req, res) => {
    let roomId = '';
    if (req.body.roomId){
        roomId = req.body.roomId;
    }else{
        const body = JSON.parse(req.body);
        roomId = body.roomId;
    }
    const documentRef = firestore.collection('rooms').doc(roomId);
    const docRefs = [];
    let result = {
        success: false,
        error: "Room not found"
    };
    const queryDocumentSnapshot = await documentRef.get();
    if (queryDocumentSnapshot.exists){
        result.success = true;
        result.error = null;
        //functions.logger.info("Hello logs!", queryDocumentSnapshot.data());
        const collectionRef = documentRef.collection('messages');
        await collectionRef.get().then(querySnapshot => {
            const docs = querySnapshot.docs;
            for (let doc of docs) {
                const data = doc.data();
                data.id = doc.id
                docRefs.push(data);
            }
            return null;
        })
        result.messages = docRefs;
    }
    res.json({ result })
});