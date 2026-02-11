#!/usr/bin/env node

const { ImapFlow } = require("imapflow");
const fs = require("fs");
const path = require("path");

const CONFIG_DIR = __dirname;

function getAppPassword(account) {
  const passFile = path.join(CONFIG_DIR, account);
  if (!fs.existsSync(passFile)) {
    console.error(`Error: no App Password found at ${passFile}`);
    console.error("");
    console.error("Create it:");
    console.error(`  mkdir -p ${CONFIG_DIR}`);
    console.error(`  echo 'xxxx xxxx xxxx xxxx' > ${passFile}`);
    console.error(`  chmod 600 ${passFile}`);
    process.exit(1);
  }
  return fs.readFileSync(passFile, "utf8").trim();
}

function createClient(account, appPassword) {
  const host = process.env.IMAP_HOST || "imap.gmail.com";
  const port = parseInt(process.env.IMAP_PORT || "993", 10);
  return new ImapFlow({
    host: host,
    port: port,
    secure: true,
    tls: { servername: "imap.gmail.com" },
    auth: {
      user: account,
      pass: appPassword,
    },
    logger: false,
  });
}

function stripAngleBrackets(messageId) {
  if (!messageId) return "";
  return messageId.replace(/^<|>$/g, "");
}

function buildGmailLink(account, messageId) {
  const bare = stripAngleBrackets(messageId);
  return `https://mail.google.com/mail/u/?authuser=${encodeURIComponent(account)}#search/rfc822msgid:${encodeURIComponent(bare)}`;
}

function normalizeSubject(subject) {
  return (subject || "")
    .replace(/^(re|fwd?|aw|sv|vs)\s*:\s*/gi, "")
    .trim();
}

function formatAddress(addrList) {
  if (!addrList || !addrList[0]) return "";
  const a = addrList[0];
  return a.name ? `${a.name} <${a.address}>` : a.address || "";
}

// --- SCAN command ---

async function scanCommand(account) {
  const appPassword = getAppPassword(account);
  const client = createClient(account, appPassword);

  try {
    await client.connect();
  } catch (err) {
    console.error(`Error connecting to IMAP: ${err.message}`);
    process.exit(1);
  }

  let conversations = [];

  try {
    // Check if the 'gtd' mailbox exists
    const mailboxes = await client.list();
    const gtdMailbox = mailboxes.find(
      (m) => m.name.toLowerCase() === "gtd" || m.path.toLowerCase() === "gtd"
    );

    if (!gtdMailbox) {
      console.log(JSON.stringify({ account, conversations: [] }, null, 2));
      await client.logout();
      return;
    }

    const lock = await client.getMailboxLock(gtdMailbox.path);
    try {
      if (client.mailbox.exists === 0) {
        console.log(JSON.stringify({ account, conversations: [] }, null, 2));
        return;
      }

      // Fetch all messages, then group by normalized subject
      const msgs = [];
      for await (const msg of client.fetch("1:*", {
        uid: true,
        envelope: true,
      })) {
        msgs.push(msg);
      }

      // Group by normalized subject
      const groups = new Map();
      for (const msg of msgs) {
        const key = normalizeSubject(msg.envelope.subject);
        if (!groups.has(key)) groups.set(key, []);
        groups.get(key).push(msg);
      }

      for (const [, msgs] of groups) {
        // Sort by date descending — latest message represents the conversation
        msgs.sort((a, b) => (b.envelope.date || 0) - (a.envelope.date || 0));
        const latest = msgs[0];

        conversations.push({
          subject: latest.envelope.subject || "",
          from: formatAddress(latest.envelope.from),
          date: latest.envelope.date ? latest.envelope.date.toISOString() : "",
          messageCount: msgs.length,
          uids: msgs.map((m) => m.uid),
          link: buildGmailLink(account, latest.envelope.messageId),
        });
      }

      // Sort conversations by date descending
      conversations.sort((a, b) => (b.date || "").localeCompare(a.date || ""));
    } finally {
      lock.release();
    }
  } finally {
    await client.logout();
  }

  console.log(JSON.stringify({ account, conversations }, null, 2));
}

// --- CLEAR command ---

async function clearCommand(account, uids) {
  const appPassword = getAppPassword(account);
  const client = createClient(account, appPassword);

  try {
    await client.connect();
  } catch (err) {
    console.error(`Error connecting to IMAP: ${err.message}`);
    process.exit(1);
  }

  try {
    const mailboxes = await client.list();
    const gtdMailbox = mailboxes.find(
      (m) => m.name.toLowerCase() === "gtd" || m.path.toLowerCase() === "gtd"
    );

    if (!gtdMailbox) {
      console.error("Error: 'gtd' mailbox not found");
      process.exit(1);
    }

    const lock = await client.getMailboxLock(gtdMailbox.path);
    try {
      // In Gmail IMAP, deleting from a label folder removes the label
      const uidNums = uids.map(Number);
      await client.messageDelete(uidNums, { uid: true });
    } finally {
      lock.release();
    }
  } finally {
    await client.logout();
  }

  console.log(
    JSON.stringify({
      account,
      cleared: uids.length,
      uids,
    })
  );
}

// --- Main ---

async function main() {
  const [, , command, account, ...rest] = process.argv;

  switch (command) {
    case "scan":
      if (!account) {
        console.error("Usage: node index.js scan <account-email>");
        process.exit(1);
      }
      await scanCommand(account);
      break;
    case "clear":
      if (!account || rest.length === 0) {
        console.error(
          "Usage: node index.js clear <account-email> <uid> [uid...]"
        );
        process.exit(1);
      }
      await clearCommand(account, rest);
      break;
    default:
      console.error(
        "Usage: node index.js <scan|clear> <account-email> [args...]"
      );
      console.error("");
      console.error("Commands:");
      console.error(
        "  scan <email>              List emails labeled 'gtd' as JSON"
      );
      console.error(
        "  clear <email> <uid> [uid..] Remove 'gtd' label from messages"
      );
      console.error("");
      console.error("Setup:");
      console.error(
        `  echo 'xxxx xxxx xxxx xxxx' > ${CONFIG_DIR}/<email>`
      );
      process.exit(1);
  }
}

main().catch((err) => {
  console.error(`Error: ${err.message}`);
  process.exit(1);
});
