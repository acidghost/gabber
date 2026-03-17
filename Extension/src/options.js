import { DISPLAY_PREFERENCE } from "./gabber.js";

async function loadPreference() {
  const result = await window.browser.storage.local.get(DISPLAY_PREFERENCE);
  const preference = result[DISPLAY_PREFERENCE] || "pageAction";
  const radio = document.querySelector(
    `input[name="displayPreference"][value="${preference}"]`,
  );
  if (radio) {
    radio.checked = true;
  }
}

async function savePreference(preference) {
  await window.browser.storage.local.set({ [DISPLAY_PREFERENCE]: preference });
}

document
  .querySelectorAll('input[name="displayPreference"]')
  .forEach((radio) => {
    radio.addEventListener("change", async (event) => {
      if (event.target.checked) {
        await savePreference(event.target.value);
      }
    });
  });

loadPreference();
