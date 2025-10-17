"use client";

import { motion } from "framer-motion";
import styles from "./page.module.css";

export default function Home() {
  return (
    <main className={styles.main}>
      <motion.div
        className={styles.hero}
        initial={{ opacity: 0, y: 16 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, ease: "easeOut" }}
      >
        <h1>Welcome to Morning Ritual</h1>
        <p>Customize this page to kickstart your Next.js app.</p>
      </motion.div>
    </main>
  );
}
