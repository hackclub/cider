import { useCallback, useEffect, useState } from "react";
import {
  Text,
  View,
  SafeAreaView,
  ScrollView,
  TouchableWithoutFeedback,
  Keyboard,
  ImageBackground,
  Pressable,
  RefreshControl,
} from "react-native";
let gradient = require("../../assets/images/homeScreen.png");
import styles from "../../assets/styles/style";
import AsyncStorage from "@react-native-async-storage/async-storage";
import LibraryItem from "@/components/LibraryItem";
import Octicons from "@expo/vector-icons/Octicons";

export default function Library() {
  let [searchResults, setSearchResults] = useState<string[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    searchBooks(true);
  }, []);
  useEffect(() => {
    searchBooks(false);
  }, []);
  async function searchBooks(refresh = false) {
    setSearchResults([]);
    let bookList = await AsyncStorage.getItem(`@shelfie:booklist`);
    let parsedBookList = bookList ? bookList.split(",") : [];
    if (parsedBookList.length === 0) {
      setSearchResults(["404shelfieerror"]);
      if (refresh) {
        setRefreshing(false);
      }
    } else {
      let mapSearchResults: string[] = [];
      parsedBookList.map((etag: string) => {
        mapSearchResults.push(etag);
      });
      setSearchResults(mapSearchResults);
      if (refresh) {
        setRefreshing(false);
      }
    }
  }

  return (
    <ImageBackground
      source={gradient}
      style={styles.image}
      imageStyle={{ opacity: 0.6 }}
    >
      <ScrollView
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        <SafeAreaView style={styles.container}>
          <TouchableWithoutFeedback
            onPress={Keyboard.dismiss}
            accessible={false}
          >
            <View>
                <Text style={styles.title}>shelf</Text>
              <View
                style={{
                  alignItems: "center",
                  justifyContent: "center",
                  width: "90%",
                }}
              >
                {searchResults.length > 0 ? (
                  searchResults.map((etag: string, index: number) =>
                    etag !== "404shelfieerror" ? (
                      <LibraryItem etag={etag} key={index} />
                    ) : (
                      <View
                        style={{
                          margin: 10,
                          marginTop: 50,
                          borderRadius: 9,
                          width: 325,
                          alignItems: "center",
                        }}
                        key={0}
                      >
                        <Text
                          style={{
                            fontSize: 20,
                            fontWeight: "bold",
                          }}
                        >
                          No books in your library.
                        </Text>
                        <Text> Add one from the search page!</Text>
                      </View>
                    )
                  )
                ) : (
                  <View
                    style={{
                      margin: 10,
                      marginTop: 50,
                      borderRadius: 9,
                      width: 325,
                      alignItems: "center",
                    }}
                  >
                    <Text style={{ fontSize: 20, fontWeight: "bold" }}>
                      Loading library...
                    </Text>
                  </View>
                )}
              </View>
            </View>
          </TouchableWithoutFeedback>
        </SafeAreaView>
      </ScrollView>
    </ImageBackground>
  );
}
