/**
 * Returns true when the URL is on a repository.
 * @param {string} url
 * @returns {boolean}
 */
export function isOnRepo(url) {
  let parsedURL;
  try {
    parsedURL = new URL(url);
  } catch {
    return false;
  }

  if (parsedURL.hostname !== "github.com") {
    return false;
  }

  const pathParts = parsedURL.pathname.split("/").filter((part) => part !== "");
  if (pathParts.length < 2) {
    return false;
  }

  const nonRepoFirstPaths = [
    "about",
    "collections",
    "copilot",
    "customer-stories",
    "dashboard",
    "enterprise",
    "events",
    "explore",
    "features",
    "issues",
    "login",
    "logout",
    "marketplace",
    "new",
    "notifications",
    "orgs",
    "pricing",
    "pulls",
    "search",
    "security",
    "settings",
    "signup",
    "sponsors",
    "team",
    "topics",
  ];

  if (nonRepoFirstPaths.includes(pathParts[0])) {
    return false;
  }

  return true;
}

/**
 * Converts the URL into a gabber:// URL.
 * @param {string} url
 * @returns {string} gabber:// URL
 */
export function asGabber(url) {
  return url.replace(/^https?/, "gabber");
}

/**
 * Open given tab's URL as a gabber:// URL.
 * @param {browser.tabs.Tab} tab
 */
export async function openInGabber(tab) {
  await window.browser.tabs.create({
    url: asGabber(tab.url),
    openerTabId: tab.id,
    active: true,
  });
}

export const DISPLAY_PREFERENCE = "displayPreference";
export const ICON_PREFERENCE = "iconPreference";
