"use client";

import { motion } from "framer-motion";
import styles from "./page.module.css";

export default function Home() {
  return (
    <main className={styles.shell}>
      <div className={styles.backdrop}>
        <motion.span
          className={styles.sun}
          animate={{ scale: [1, 1.06, 1], opacity: [0.85, 1, 0.85] }}
          transition={{ duration: 12, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.span
          className={`${styles.orb} ${styles.orbLeft}`}
          animate={{ y: [0, -18, 0], rotate: [0, 4, -3, 0] }}
          transition={{ duration: 16, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.span
          className={`${styles.orb} ${styles.orbRight}`}
          animate={{ y: [0, 22, 0], rotate: [0, -5, 3, 0] }}
          transition={{ duration: 18, repeat: Infinity, ease: "easeInOut" }}
        />
        <div className={styles.grain} />
      </div>

      <div className={styles.inner}>
        <header className={styles.hero}>
          <motion.span
            className={styles.badge}
            initial={{ y: -12, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.1, duration: 0.6, ease: "easeOut" }}
          >
            今日能量航图
          </motion.span>
          <motion.h1
            className={styles.headline}
            initial={{ y: 30, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.2, duration: 0.65, ease: "easeOut" }}
          >
            晨间能量舱
          </motion.h1>
          <motion.p
            className={styles.lede}
            initial={{ y: 36, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.26, duration: 0.6, ease: "easeOut" }}
          >
            复古卡通风的柔光中，慢慢写下你的晨间仪式。感恩、期待、自豪与自爱，将在这里编织成今日的能量电流。
          </motion.p>
        </header>

        <section className={styles.placeholder}>
          <p>这里是你的晨间仪式内容区域，后续可按需自定义。</p>
        </section>
      </div>
    </main>
  );
}
