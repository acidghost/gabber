import { asGabber } from "./gabber.js";

const popup = document.getElementById("popup-content");
popup.innerHTML = "";

const tab = await window.browser.tabs
  .query({ active: true, currentWindow: true })
  .then((ts) => ts[0]);
console.log(`active tab ${tab.url}`);

const a = document.createElement("a");
a.href = asGabber(tab.url);
a.innerText = tab.url;
popup.appendChild(a);

window.browser.tabs.create({ url: a.href, openerTabId: tab.id });
