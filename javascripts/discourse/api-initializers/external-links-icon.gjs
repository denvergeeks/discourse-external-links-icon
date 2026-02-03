import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("0.11.1", (api) => {
  api.decorateCooked(addIcons);

  function addIcons(container) {
    if (!container?.querySelectorAll) return;

    const links = container.querySelectorAll("a[href]:not([data-ext-icon])");
    
    links.forEach((link) => {
      link.setAttribute("data-ext-icon", "processed");

      // Exclusions
      if (link.closest(".fancy-title, .topic-link, .onebox, .breadcrumb, .quote") ||
          link.matches("a.title, .mention, .hashtag, [data-user-card], .back") ||
          link.querySelector("img")) {
        return;
      }
      
      let linkUrl;
      try {
        linkUrl = new URL(link.href);
      } catch {
        return;
      }
      
      if (!["http:", "https:"].includes(linkUrl.protocol) ||
          linkUrl.hostname === window.location.hostname) {
        return;
      }

      // Add icon
      const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      svg.setAttribute('class', 'fa d-icon d-icon-up-right-from-square svg-icon ext-icon');
      svg.setAttribute('aria-hidden', 'true');
      svg.innerHTML = '<use href="#up-right-from-square"></use>';
      
      link.appendChild(svg);
      link.setAttribute("data-ext-icon", "true");
    });
  }
});
