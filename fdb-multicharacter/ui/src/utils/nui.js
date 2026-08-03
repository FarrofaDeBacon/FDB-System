const RESOURCE_NAME = 'fdb-multicharacter';

export async function fetchNui(endpoint, data = {}) {
  try {
    const resp = await fetch(`https://${RESOURCE_NAME}/${endpoint}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data)
    });
    return await resp.json();
  } catch (e) {
    console.error(`fetchNui error (${endpoint}):`, e);
    return null;
  }
}
