"use strict";

(async () => {
  const popup = document.getElementById("popup-content");
  popup.innerHTML = "";

  const tab = await browser.tabs.query({ active: true, currentWindow: true }).then(ts => ts[0]);
  console.log(`active tab ${tab.url}`);

  const a = document.createElement("a");
  a.href = tab.url.replace(/^https?/, "gabber");
  a.innerText = tab.url;
  popup.appendChild(a);

  browser.tabs.create({ url: a.href, openerTabId: tab.id });
})();
