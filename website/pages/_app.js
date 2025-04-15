import "../styles/globals.css";
import { ThemeProvider } from "next-themes";
import { Provider } from "react-wrap-balancer";
import Banner from "../components/Banner";

function MyApp({ Component, pageProps }) {
  return (
    <ThemeProvider defaultTheme="light" attribute="class">
      <Provider>
        <Component {...pageProps} />
      </Provider>
    </ThemeProvider>
  );
}

export default MyApp;
