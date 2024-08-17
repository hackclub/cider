import { Text, View } from "react-native";
import Octicons from "@expo/vector-icons/Octicons";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { createStackNavigator } from "@react-navigation/stack";
import HomeScreen from "./HomeScreen";
import Library from "./Library";
import Settings from "./Settings";
import styles from "../../assets/styles/style";
import Bulletin from "./Bulletin";
import Swipes from "./Swipes";
const Tab = createBottomTabNavigator();
const ModalStack = createStackNavigator();
export default function Home() {
  
  function ModalScreen() {
    return (
      <View
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: 20,
          backgroundColor: "#F8F8F8",
          shadowColor: "#37B7C3",
          shadowOpacity: 0.5,
          shadowRadius: 48,
          elevation: 5,
        }}
      >
        <Text>hi</Text>
      </View>
    );
  }
  return (
    <>
      <Tab.Navigator
        screenOptions={{
          headerShown: false,
          tabBarShowLabel: false,
          tabBarStyle: {
            /*position: "absolute",
            bottom: 25,
            left: 33.5,
            width: 325,*/
            position: 'absolute',
            bottom: "3%",
            left: "7.5%",
            width: '85%',
            alignSelf: "center",
            height: 60,
            shadowColor: "#37B7C3",
            shadowOpacity: 0.5,
            shadowRadius: 48,
            borderRadius: 64,
            elevation: 10,
            backgroundColor: "#F8F8F8",
            backfaceVisibility: "hidden",
          },
          tabBarActiveTintColor: "#37B7C3",
          tabBarIconStyle: styles.tabBarIcon,
        }}
      >
        <Tab.Screen
          name="Bulletin"
          component={Bulletin}
          options={{
            tabBarIcon: ({ color, size }) => (
              <Octicons name="home" color={color} size={size} />
            ),
          }}
        />
        <Tab.Screen
          name="Home"
          component={HomeScreen}
          options={{
            tabBarIcon: ({ color, size }) => (
              <Octicons name="telescope" color={color} size={size} />
            ),
          }}
        />

        <Tab.Screen
          name="Swipe"
          component={Swipes}
          options={{
            tabBarIcon: ({ color, size }) => (
              <Octicons name="heart" color={color} size={size} />
            ),
          }}
        />
        <Tab.Screen
          name="Library"
          component={Library}
          options={{
            tabBarIcon: ({ color, size }) => (
              <Octicons name="repo" color={color} size={size} />
            ),
          }}
        />

        <Tab.Screen
          name="Settings"
          component={Settings}
          options={{
            tabBarIcon: ({ color, size }) => (
              <Octicons name="gear" color={color} size={size} />
            ),
          }}
        />
      </Tab.Navigator>
    </>
  );
}
