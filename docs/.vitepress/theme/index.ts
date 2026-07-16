import DefaultTheme from "vitepress/theme";
import { h } from "vue";
import type { Theme } from "vitepress";
import MarketingHome from "./components/MarketingHome.vue";
import "./custom.css";

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      "home-features-after": () => h(MarketingHome),
    });
  },
} satisfies Theme;
