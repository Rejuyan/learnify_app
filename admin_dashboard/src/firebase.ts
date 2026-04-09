import { initializeApp } from 'firebase/app';
import { getAuth, signInWithEmailAndPassword, signOut, onAuthStateChanged } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

const firebaseConfig = {
  apiKey: 'AIzaSyAzwpo8Q_eVQkXfwNMc5BJstz-QYSNoGc4',
  authDomain: 'learnify-2a174.firebaseapp.com',
  projectId: 'learnify-2a174',
  storageBucket: 'learnify-2a174.firebasestorage.app',
  messagingSenderId: '553001438440',
  appId: '1:553001438440:web:3dc029955bf8e34272cd5d',
  measurementId: 'G-RNYPNTC09J',
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

export { signInWithEmailAndPassword, signOut, onAuthStateChanged };
