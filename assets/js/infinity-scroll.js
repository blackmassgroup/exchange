export default {
  rootElement() {
    return (
      document.documentElement || document.body.parentNode || document.body
    );
  },
  scrollPosition() {
    const { scrollTop, clientHeight, scrollHeight } = this.rootElement();
    return ((scrollTop + clientHeight) / scrollHeight) * 100;
  },
  mounted() {
    this.threshold = 95;
    this.lastScrollPosition = 0;
    const scrollToTopBtn = document.getElementById(
      "infinity-scroll-scroll-to-top"
    );
    window.addEventListener("scroll", () => {
      const currentScrollPosition = this.scrollPosition();
      const isCloseToBottom =
        currentScrollPosition > this.threshold &&
        this.lastScrollPosition <= this.threshold;
      if (isCloseToBottom) {
        this.pushEvent("load-more", {});
      }
      this.lastScrollPosition = currentScrollPosition;
      const rootElement = document.documentElement;
      const scrollTotal = rootElement.scrollHeight - rootElement.clientHeight;
      if (rootElement.scrollTop / scrollTotal > 0.6) {
        scrollToTopBtn.classList.add("show-scroll-to-top-btn");
      } else {
        scrollToTopBtn.classList.remove("show-scroll-to-top-btn");
      }
    });
  },
};
