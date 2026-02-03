import { apiInitializer } from "discourse/lib/api";
import { iconNode } from "discourse-common/lib/icon-library";

export default apiInitializer("0.11.1", (api) => {
  api.decorateCooked((cookedEl) => {
    addIcons(cookedEl);
  });

  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      mutation.addedNodes.forEach((node) => {
        if (node.nodeType === 1 && node.querySelector("a[href]")) {
          addIcons(node);
        }
      });
    });
  });
  observer.observe(document.body, { childList: true, subtree: true });

  function addIcons(container) {
    const links = container.querySelectorAll("a[href]:not([data-ext-icon])");
    if (!links.length) {
      return;
    }

    links.forEach((link) => {
      // Set the attribute immediately to prevent reprocessing by other mutations
      link.setAttribute("data-ext-icon", "true");

      // Use link.href which is always the fully qualified URL
      const linkUrl = new URL(link.href);

      // 1. Skip non-http protocols
      if (!["http:", "https:"].includes(linkUrl.protocol)) {
        return;
      }

      // 2. Skip internal links by comparing hostnames
      if (linkUrl.hostname === window.location.hostname) {
        return;
      }
      
      // 3. Skip links that are already special in some way
      if (link.matches(".mention, .hashtag, [data-user-card], .onebox, .breadcrumb a, .back")) {
        return;
      }

      const svgIcon = iconNode("up-right-from-square", { class: "ext-icon" });
      link.appendChild(svgIcon);
    });
  }
});
