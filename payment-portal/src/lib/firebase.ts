import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || "AIzaSyDTytb6e4KB_trbHysxftfwG-sYMwB_a2M",
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || "supamobile-26.firebaseapp.com",
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || "supamobile-26",
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || "supamobile-26.firebasestorage.app",
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || "132584247749",
  appId: import.meta.env.VITE_FIREBASE_APP_ID || "1:132584247749:web:c6f5713a890a6924b9bbac",
  measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID || "G-N0242HY0KV"
};

export const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
