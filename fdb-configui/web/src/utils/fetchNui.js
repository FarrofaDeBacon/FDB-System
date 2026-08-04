export async function fetchNui(eventName, data = {}) {
    const options = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data),
    };

    const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'fdb-configui';
    const resp = await fetch(`https://${resourceName}/${eventName}`, options);
    return await resp.json();
}
