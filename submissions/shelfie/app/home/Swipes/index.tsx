import { ImageBackground } from "react-native";
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
let gradient = require("../../../assets/images/homeScreen.png");
import SwipeScreen from "./SwipeScreen";
import Start from "./Start";
import styles from "../../../assets/styles/style";


const Stack = createNativeStackNavigator();

export default function Swipes() {
  return (
    <ImageBackground
      source={gradient}
      style={styles.image}
      imageStyle={{ opacity: 0.6 }}
    >
      <NavigationContainer independent={true}>
        <Stack.Navigator
          screenOptions={{
            headerShown: false,
            contentStyle: {
              backgroundColor: "#fff",
            },
            animation: "fade"
          }}
        >
          <Stack.Screen name="Start Page" component={Start}/>
          <Stack.Screen name="SwipeScreen" component={SwipeScreen} />
        </Stack.Navigator>
      </NavigationContainer>
    </ImageBackground>
  );
}
