import { DISPLAY_PREFERENCE, isOnRepo, openInGabber } from "./gabber.js";

const MENU_ID = "gabber-context-menu";

/**
 * Gets the current display preference from storage.
 * @returns {Promise<string>} The display preference ("pageAction", "contextMenu", or "both")
 */
async function getDisplayPreference() {
  const result = await window.browser.storage.local.get(DISPLAY_PREFERENCE);
  return result[DISPLAY_PREFERENCE] || "pageAction";
}

/**
 * Determines if the page action should be shown based on user preference.
 * @returns {Promise<boolean>} True if page action should be shown
 */
async function shouldShowPageAction() {
  const preference = await getDisplayPreference();
  return preference === "pageAction" || preference === "both";
}

/**
 * Determines if the context menu should be shown based on user preference.
 * @returns {Promise<boolean>} True if context menu should be shown
 */
async function shouldShowContextMenu() {
  const preference = await getDisplayPreference();
  return preference === "contextMenu" || preference === "both";
}

/**
 * Updates the visibility of page action and context menu for a tab.
 * @param {browser.tabs.Tab} tab - The tab to update visibility for
 * @returns {Promise<void>}
 */
async function updateVisibility(tab) {
  const onRepo = isOnRepo(tab.url);

  if (onRepo) {
    if (await shouldShowPageAction()) {
      console.debug(`Showing page action in tab ${tab.id} with URL ${tab.url}`);
      window.browser.pageAction.show(tab.id);
    } else {
      console.debug(`Hiding page action in tab ${tab.id} with URL ${tab.url}`);
      window.browser.pageAction.hide(tab.id);
    }

    window.browser.contextMenus.update(MENU_ID, {
      visible: await shouldShowContextMenu(),
    });
  } else {
    console.debug(`Hiding page action in tab ${tab.id} with URL ${tab.url}`);
    window.browser.pageAction.hide(tab.id);
  }
}

window.browser.tabs.onUpdated.addListener((_tabId, _change, tab) => {
  updateVisibility(tab);
});

window.browser.runtime.onInstalled.addListener(async () => {
  window.browser.contextMenus.create({
    id: MENU_ID,
    title: "Open in Gabber",
    contexts: ["page", "link"],
  });

  const tabs = await window.browser.tabs.query({});
  for (let tab of tabs) {
    await updateVisibility(tab);
  }
});

window.browser.contextMenus.onClicked.addListener(async (info, tab) => {
  if (info.menuItemId === MENU_ID) {
    await openInGabber(tab);
  }
});

window.browser.storage.onChanged.addListener(async (changes, areaName) => {
  if (areaName === "local" && changes[DISPLAY_PREFERENCE]) {
    const tabs = await window.browser.tabs.query({});
    for (let tab of tabs) {
      await updateVisibility(tab);
    }
  }
});
