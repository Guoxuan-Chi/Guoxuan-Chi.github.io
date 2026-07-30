(() => {
  const config = window.facultyLanguageRouting || {};
  const storageKey = "faculty-language";

  const readPreference = () => {
    try {
      return window.localStorage.getItem(storageKey);
    } catch (_error) {
      return null;
    }
  };

  const savePreference = (language) => {
    try {
      window.localStorage.setItem(storageKey, language);
    } catch (_error) {
      // The language switch still works when storage is unavailable.
    }
  };

  if (config.isHome && config.current === "en") {
    const stored = readPreference();
    const browserLanguage = (navigator.languages && navigator.languages[0]) || navigator.language || "";
    const preferred = stored || (browserLanguage.toLowerCase().startsWith("zh") ? "zh" : "en");

    if (preferred === "zh" && config.translation) {
      savePreference("zh");
      window.location.replace(config.translation);
      return;
    }
  }

  window.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll("[data-language-choice]").forEach((link) => {
      link.addEventListener("click", () => {
        savePreference(link.getAttribute("data-language-choice"));
      });
    });
  });
})();
