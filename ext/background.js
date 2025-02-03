"use strict";

const DOMAINS = [
  /^https?:\/\/github\.com\/.+\/.+$/,
];

(async () => {
  const tabs = await browser.tabs.query({});
  for (let tab of tabs) {
    if (DOMAINS.some(domain => domain.test(tab.url))) {
      console.debug(`Showing page action in tab ${tab.id} with URL ${tab.url}`);
      browser.pageAction.show(tab.id);
    }
  }

  browser.tabs.onUpdated.addListener((_tabId, _change, tab) => {
    if (DOMAINS.some(domain => domain.test(tab.url))) {
      console.debug(`Showing page action in tab ${tab.id} with URL ${tab.url}`);
      browser.pageAction.show(tab.id);
    } else {
      console.debug(`Hiding page action in tab ${tab.id} with URL ${tab.url}`);
      browser.pageAction.hide(tab.id);
    }
  });
})();
