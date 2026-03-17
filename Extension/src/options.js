import { DISPLAY_PREFERENCE, ICON_PREFERENCE } from "./gabber.js";

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

async function loadIconPreference() {
  const result = await window.browser.storage.local.get(ICON_PREFERENCE);
  const preference = result[ICON_PREFERENCE] || "icons/gabber-48.png";
  const radio = document.querySelector(
    `input[name="iconPreference"][value="${preference}"]`,
  );
  if (radio) {
    radio.checked = true;
  }
}

async function saveIconPreference(path) {
  await window.browser.storage.local.set({ [ICON_PREFERENCE]: path });
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

document.querySelectorAll('input[name="iconPreference"]').forEach((radio) => {
  radio.addEventListener("change", async (event) => {
    if (event.target.checked) {
      await saveIconPreference(event.target.value);
    }
  });
});

loadPreference();
loadIconPreference();
