import { isOnRepo } from "./gabber.js";

const tabs = await window.browser.tabs.query({});
for (let tab of tabs) {
  if (isOnRepo(tab.url)) {
    console.debug(`Showing page action in tab ${tab.id} with URL ${tab.url}`);
    window.browser.pageAction.show(tab.id);
  }
}

window.browser.tabs.onUpdated.addListener((_tabId, _change, tab) => {
  if (isOnRepo(tab.url)) {
    console.debug(`Showing page action in tab ${tab.id} with URL ${tab.url}`);
    window.browser.pageAction.show(tab.id);
  } else {
    console.debug(`Hiding page action in tab ${tab.id} with URL ${tab.url}`);
    window.browser.pageAction.hide(tab.id);
  }
});
