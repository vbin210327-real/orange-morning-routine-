"use client";

import { useEffect, useMemo, useState } from "react";
import styles from "./page.module.css";
import { useAuth } from "@/hooks/use-auth";
import { db } from "@/lib/instant";
import { motion } from "framer-motion";
import Image from "next/image";

const DEFAULT_AVATAR = "https://avatar.vercel.sh/ritual";

export default function ProfilePage() {
  const { user, refresh, signOut } = useAuth();

  const [displayName, setDisplayName] = useState("");
  const [bio, setBio] = useState("");
  const [avatarUrl, setAvatarUrl] = useState(DEFAULT_AVATAR);
  const [isSaving, setIsSaving] = useState(false);
  const [status, setStatus] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const { data } = db.useQuery(
    user
      ? {
          users: {
            $: { where: { id: user.id } },
          },
        }
      : null,
  );

  useEffect(() => {
    if (!data?.users?.length) return;
    const profile = data.users[0];
    setDisplayName(profile.displayName ?? "");
    setBio(profile.bio ?? "");
    setAvatarUrl(profile.avatarUrl ?? DEFAULT_AVATAR);
  }, [data?.users]);

  const initials = useMemo(() => {
    if (displayName) {
      return displayName
        .split(" ")
        .map((chunk) => chunk.charAt(0))
        .join("")
        .toUpperCase();
    }
    if (user?.email) {
      return user.email.charAt(0).toUpperCase();
    }
    return "你";
  }, [displayName, user?.email]);

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);
    setStatus(null);

    if (!user) {
      setError("登录状态已失效，请重新登录");
      return;
    }

    setIsSaving(true);
    try {
      await db.transact(
        db.tx.users[user.id].update({
          displayName: displayName || null,
          bio: bio || null,
          avatarUrl: avatarUrl || DEFAULT_AVATAR,
          lastLoginAt: Date.now(),
        }),
      );
      await refresh();
      setStatus("个人资料已更新");
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <main className={styles.page}>
      <motion.div
        className={styles.panel}
        initial={{ opacity: 0, y: 28 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, ease: "easeOut" }}
      >
        <section className={styles.meta}>
          <div className={styles.avatarPreview}>
            {avatarUrl ? (
              <Image src={avatarUrl} alt="avatar" width={120} height={120} />
            ) : (
              initials
            )}
          </div>
          <h2>你好，{displayName || initials}</h2>
          <p>
            这里是你的个人主页，可以修改称呼、头像与自我介绍。完成后保存即可与晨间仪式数据同步，在不同设备都能看到最新状态。
          </p>
        </section>
        <section className={styles.formSection}>
          <h3>编辑个人信息</h3>
          <form className={styles.form} onSubmit={handleSubmit}>
            <div className={styles.field}>
              <div className={styles.labelRow}>
                <label htmlFor="displayName">称呼</label>
                <span>{displayName.trim().length}/30</span>
              </div>
              <input
                id="displayName"
                className={styles.input}
                maxLength={30}
                placeholder="想让自己被如何称呼？"
                value={displayName}
                onChange={(event) => setDisplayName(event.target.value)}
              />
            </div>
            <div className={styles.field}>
              <div className={styles.labelRow}>
                <label htmlFor="avatar">头像地址</label>
                <button
                  type="button"
                  className={styles.buttonSecondary}
                  onClick={() => setAvatarUrl(DEFAULT_AVATAR)}
                >
                  使用默认
                </button>
              </div>
              <input
                id="avatar"
                className={styles.input}
                placeholder="https://..."
                value={avatarUrl}
                onChange={(event) => setAvatarUrl(event.target.value)}
              />
            </div>
            <div className={styles.field}>
              <div className={styles.labelRow}>
                <label htmlFor="bio">自我介绍</label>
                <span>{bio.trim().length}/160</span>
              </div>
              <textarea
                id="bio"
                className={styles.textarea}
                maxLength={160}
                placeholder="写下你的晨间宣言、能量口号或今日的愿景。"
                value={bio}
                onChange={(event) => setBio(event.target.value)}
              />
            </div>

            {error ? <div className={`${styles.status} ${styles.error}`}>{error}</div> : null}
            {status ? <div className={styles.status}>{status}</div> : null}

            <div className={styles.actions}>
              <button type="button" className={styles.buttonSecondary} onClick={signOut}>
                退出登录
              </button>
              <motion.button
                type="submit"
                className={styles.buttonPrimary}
                whileTap={{ scale: 0.97 }}
                disabled={isSaving}
              >
                {isSaving ? "保存中..." : "保存信息"}
              </motion.button>
            </div>
          </form>
        </section>
      </motion.div>
    </main>
  );
}

