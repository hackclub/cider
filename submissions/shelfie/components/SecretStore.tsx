import * as SecureStore from 'expo-secure-store';

export async function set(key: string, value: string) {
  await SecureStore.setItemAsync(key, value);
}

export async function get(key: string) {
  let result = await SecureStore.getItemAsync(key);
  if (result) {
    return result;
  } else {
    return null;
  }
}

export async function deleteSecret(key: string) {
  await SecureStore.deleteItemAsync(key);
  return true;
}