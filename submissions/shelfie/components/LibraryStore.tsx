import AsyncStorage from "@react-native-async-storage/async-storage";
import { Alert } from "react-native";

export async function storeBook(etag: string, book: object) {
  try {
    let bookList = await AsyncStorage.getItem(`@shelfie:booklist`);
    let parsedBookList = bookList ? bookList.split(",") : [];
    if (parsedBookList.includes(etag)) {
      await AsyncStorage.removeItem(`@shelfie:${etag}`);
      const index = parsedBookList.indexOf(etag);
      if (index > -1) {
        parsedBookList.splice(index, 1);
      }
      await AsyncStorage.setItem(`@shelfie:booklist`, parsedBookList.join(","));
    } else {
      await AsyncStorage.setItem(`@shelfie:${etag}`, JSON.stringify(book));
      parsedBookList.push(etag);
      await AsyncStorage.setItem(`@shelfie:booklist`, parsedBookList.join(","));
      console.log("added to library");
    }
  } catch (error) {
    Alert.alert("Error saving book to library.");
  }
}

export async function getBook(etag: string) {
  try {
    const value = await AsyncStorage.getItem(`@shelfie:${etag}`);
    return value;
  } catch (e) {
    Alert.alert("Error reading library");
  }
}

export async function clearLibrary() {
  try {
    let bookList = await AsyncStorage.getItem(`@shelfie:booklist`);
    let parsedBookList = bookList ? bookList.split(",") : [];
    for(var i=0;i<parsedBookList.length;i++) {
      parsedBookList[i] = `@shelfie:${parsedBookList[i]}`
    }
    await AsyncStorage.multiRemove(parsedBookList);
    await AsyncStorage.setItem(`@shelfie:booklist`, '')
    Alert.alert("Library cleared!")
  } catch (e) {
    Alert.alert("Error clearing library");
  }
}
export async function deleteBook(etag: string) {
  try {
    await AsyncStorage.removeItem(`@shelfie:${etag}`);
    let bookList = await AsyncStorage.getItem(`@shelfie:booklist`);
    let parsedBookList = bookList ? bookList.split(",") : [];
    const index = parsedBookList.indexOf(etag);
    if (index > -1) {
      parsedBookList.splice(index, 1);
    }
    await AsyncStorage.setItem(`@shelfie:booklist`, parsedBookList.join(","));
  } catch (e) {
    Alert.alert("Error deleting from library.");
  }
}
