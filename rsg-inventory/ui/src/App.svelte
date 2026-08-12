<script>
  import { onMount, onDestroy } from 'svelte';
  import './main.css';
  import InventoryPanel from './components/InventoryPanel.svelte';
  import ContextMenu from './components/ContextMenu.svelte';
  import TradePanel from './components/TradePanel.svelte';
  import BackpackDrawer from './components/BackpackDrawer.svelte';

  // --- Svelte 5 States ---
  let isInventoryOpen = $state(false);
  let backpack = $state(null);
  let backpackData = $state(null);
  let isBackpackOpen = $state(false);
  let satchelData = $state(null);
  let isSatchelOpen = $state(false);
  let walletData = $state(null);
  let isWalletOpen = $state(false);
  let holsterData = $state(null);
  let isHolsterOpen = $state(false);
  let playerInventory = $state({});
  let otherInventory = $state({});
  let maxWeight = $state(0);
  let totalSlots = $state(0);
  let playerId = $state(null);
  let playerName = $state(null);
  let cash = $state(0);
  let transferAmount = $state(null);
  let errorSlot = $state(null);
  let busy = $state(false);
  let equipmentSlots = $state({ backpack: null, satchel: null, wallet: null, holster: null });

  // Other inventory states
  let isOtherInventoryEmpty = $state(true);
  let otherInventoryName = $state("");
  let otherInventoryLabel = $state("Drop");
  let otherInventoryMaxWeight = $state(1000000);
  let otherInventorySlots = $state(100);
  let otherInventoryHotbarOffset = $state(null);
  let otherInventoryHotbarMaxSlots = $state(null);
  let isShopInventory = $state(false);

  // Context menu states
  let showContextMenu = $state(false);
  let contextMenuPosition = $state({ top: "0px", left: "0px" });
  let contextMenuItem = $state(null);

  // Trade states
  let isTradeActive = $state(false);
  let tradeId = $state(null);
  let tradePartnerName = $state(null);
  let myTradeOffers = $state({});
  let theirTradeOffers = $state({});
  let myTradeAccepted = $state(false);
  let theirTradeAccepted = $state(false);

  // Hotbar states
  let showHotbar = $state(false);
  let hotbarItems = $state([]);
  let activeHotbarSlots = $state([]);
  let wasHotbarEnabled = $state(false);

  // Notifications states
  let showNotification = $state(false);
  let notificationText = $state("");
  let notificationImage = $state("");
  let notificationType = $state("added");
  let notificationAmount = $state(1);
  let notificationDescription = $state("");
  let notificationClass = $state("");
  let notificationTimeout = null;

  // Hover item details state
  let selectedItem = $state(null);

  // Custom drag tracking states
  let isMouseDown = $state(false);
  let mouseDownX = $state(0);
  let mouseDownY = $state(0);
  let isDragging = $state(false);
  let dragX = $state(0);
  let dragY = $state(0);
  let currentlyDraggingItem = $state(null);
  let currentlyDraggingSlot = $state(null);
  let dragStartInventoryType = $state("player");
  let dragStartEquipmentType = $state(null);
  const dragThreshold = 5;

  // CSRF token
  let nuiToken = $state(null);

  // Translations
  let t = $state({
    title: 'RSG Inventory',
    close: 'Close',
    close_aria: 'Close inventory',
    use: 'Use',
    give: 'Give',
    single: 'Single',
    half: 'Half',
    all: 'All',
    amount: 'Amount',
    amount_placeholder: 'amount',
    drop: 'Drop',
    copy_serial: 'Copy Serial',
    sell: 'Sell',
    satchel: 'Satchel',
    pocket: 'Pocket',
    weight: 'Weight',
    id: 'ID',
    cash: 'Cash',
    received: 'Received',
    used: 'Used',
    removed: 'Removed',
    trade: 'Trade',
    your_offer: 'Your Offer',
    their_offer: 'Their Offer',
    accept: 'Accept',
    waiting: 'Waiting for other player...',
    cancel: 'Cancel',
    accepted: 'Accepted',
    no_items_offered: 'No items offered'
  });

  // --- Svelte 5 Derived (Computed) Properties ---
  const playerWeight = $derived(
    Object.values(playerInventory).reduce((total, item) => {
      if (item && item.weight !== undefined && item.amount !== undefined) {
        return total + item.weight * item.amount;
      }
      return total;
    }, 0)
  );

  const otherInventoryWeight = $derived(
    Object.values(otherInventory).reduce((total, item) => {
      if (item && item.weight !== undefined && item.amount !== undefined) {
        return total + item.weight * item.amount;
      }
      return total;
    }, 0)
  );

  const playerMoney = $derived(cash * 100);
  const shouldCenterInventory = $derived(isOtherInventoryEmpty && !isTradeActive);

  // --- NUI Callback Helper ---
  async function post(event, data = {}) {
    try {
      if (nuiToken) {
        data.token = nuiToken;
      }
      const response = await fetch(`https://fdb-inventory/${event}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data)
      });
      return await response.json();
    } catch (error) {
      console.error(`Failed callback: ${event}`, error);
      return null;
    }
  }

  function logDebug(msg) {
    post("LogDebug", { msg: msg }).catch(() => {});
  }

  async function validateToken(csrfToken) {
    try {
      const response = await fetch("https://rsg-core/validateCSRF", {
        method: "POST",
        headers: {
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ clientToken: csrfToken })
      });
      const data = await response.json();
      return data.valid;
    } catch (e) {
      console.error("Error validating CSRF:", e);
      return false;
    }
  }

  // --- Core Methods ---
  function openInventory(data) {
    console.log("[NUI App.svelte] openInventory called. backpack data present:", data.backpack != null);
    if (showHotbar) {
      wasHotbarEnabled = true;
      toggleHotbar(false);
    } else {
      wasHotbarEnabled = false;
    }

    isInventoryOpen = true;
    maxWeight = data.maxweight;
    totalSlots = data.slots;
    playerId = data.playerId || null;
    playerName = data.playerName || null;
    playerInventory = {};
    otherInventory = {};

    if (data.labels) {
      t = { ...t, ...data.labels };
    }

    if (data.cash !== undefined) {
      cash = data.cash;
    }

    if (data.inventory) {
      if (Array.isArray(data.inventory)) {
        data.inventory.forEach((item) => {
          if (item && item.slot) {
            item.inventory = "player";
            playerInventory[item.slot] = item;
          }
        });
      } else if (typeof data.inventory === "object") {
        for (const key in data.inventory) {
          const item = data.inventory[key];
          if (item && item.slot) {
            item.inventory = "player";
            playerInventory[item.slot] = item;
          }
        }
      }
    }

    if (data.other) {
      if (data.other.inventory) {
        if (Array.isArray(data.other.inventory)) {
          data.other.inventory.forEach((item) => {
            if (item && item.slot) {
              item.inventory = "other";
              otherInventory[item.slot] = item;
            }
          });
        } else if (typeof data.other.inventory === "object") {
          for (const key in data.other.inventory) {
            const item = data.other.inventory[key];
            if (item && item.slot) {
              item.inventory = "other";
              otherInventory[item.slot] = item;
            }
          }
        }
      }

      otherInventoryName = data.other.name;
      otherInventoryLabel = data.other.label || t.drop || otherInventoryLabel;
      otherInventoryMaxWeight = data.other.maxweight;
      otherInventorySlots = data.other.slots;
      otherInventoryHotbarOffset = data.other.hotbarOffset || null;
      otherInventoryHotbarMaxSlots = data.other.hotbarMaxSlots || null;

      isShopInventory = otherInventoryName.startsWith("shop-");
      isOtherInventoryEmpty = false;
    }

    // Backpack NUI data mapping
    if (data.backpack) {
      console.log("[NUI App.svelte] Mapping backpack data:", JSON.stringify(data.backpack));
      const itemsMap = {};
      const isSatchel = data.backpack.model && (data.backpack.model.includes("satchel") || data.backpack.model.startsWith("satchel_"));
      const invType = isSatchel ? "satchel" : "backpack";

      if (Array.isArray(data.backpack.items)) {
        data.backpack.items.forEach((item) => {
          if (item && item.slot) {
            item.inventory = invType;
            itemsMap[item.slot] = item;
          }
        });
      } else if (typeof data.backpack.items === "object") {
        for (const key in data.backpack.items) {
          const item = data.backpack.items[key];
          if (item && item.slot) {
            item.inventory = invType;
            itemsMap[item.slot] = item;
          }
        }
      }
      
      if (isSatchel) {
        satchelData = {
          ...data.backpack,
          items: itemsMap
        };
        if (data.backpack.autoOpen) {
          isSatchelOpen = true;
          console.log("[NUI App.svelte] Satchel auto-opened!");
        }
      } else {
        backpackData = {
          ...data.backpack,
          items: itemsMap
        };
        if (data.backpack.autoOpen) {
          isBackpackOpen = true;
          console.log("[NUI App.svelte] Backpack auto-opened!");
        }
      }
      console.log("[NUI App.svelte] Backpack mapping finished. isBackpackOpen:", isBackpackOpen, "isSatchelOpen:", isSatchelOpen);
    } else {
      backpackData = null;
      satchelData = null;
    }
    if (data.equipmentSlots && !Array.isArray(data.equipmentSlots)) {
      equipmentSlots = data.equipmentSlots;
    } else {
      equipmentSlots = { backpack: null, satchel: null, wallet: null, holster: null };
    }

    if (t && t.title) {
      document.title = t.title;
    }
  }

  function updateInventory(data) {
    playerInventory = {};
    if (data.inventory) {
      if (Array.isArray(data.inventory)) {
        data.inventory.forEach((item) => {
          if (item && item.slot) {
            item.inventory = "player";
            playerInventory[item.slot] = item;
          }
        });
      } else if (typeof data.inventory === "object") {
        for (const key in data.inventory) {
          const item = data.inventory[key];
          if (item && item.slot) {
            item.inventory = "player";
            playerInventory[item.slot] = item;
          }
        }
      }
    }
    if (data.equipmentSlots && !Array.isArray(data.equipmentSlots)) {
      equipmentSlots = data.equipmentSlots;
      if (isSatchelOpen && !equipmentSlots.satchel) {
        isSatchelOpen = false;
        satchelData = null;
      }
      if (isBackpackOpen && !equipmentSlots.backpack) {
        isBackpackOpen = false;
        backpackData = null;
      }
      if (isWalletOpen && !equipmentSlots.wallet) {
        isWalletOpen = false;
        walletData = null;
      }
      if (isHolsterOpen && !equipmentSlots.holster) {
        isHolsterOpen = false;
        holsterData = null;
      }
    } else if (data.equipmentSlots && Array.isArray(data.equipmentSlots)) {
      equipmentSlots = { backpack: null, satchel: null, wallet: null, holster: null };
      isSatchelOpen = false;
      satchelData = null;
      isBackpackOpen = false;
      backpackData = null;
      isWalletOpen = false;
      walletData = null;
      isHolsterOpen = false;
      holsterData = null;
    }
  }

  async function closeInventory() {
    let inventoryName = otherInventoryName;
    const currentWasHotbar = wasHotbarEnabled;
    const currentWasTrade = isTradeActive;
    const currentTradeId = tradeId;
    let hotbarItemsList = [];
    let hotbarActiveList = [];

    if (currentWasHotbar) {
      hotbarItemsList = [...hotbarItems];
      hotbarActiveList = [...activeHotbarSlots];
    }

    if (currentWasTrade && currentTradeId) {
      post("CancelTrade", { tradeId: currentTradeId }).catch(() => {});
    }

    // Reset States
    isInventoryOpen = false;
    playerInventory = {};
    otherInventory = {};
    maxWeight = 0;
    totalSlots = 0;
    playerId = null;
    playerName = null;
    cash = 0;
    transferAmount = null;
    isOtherInventoryEmpty = true;
    otherInventoryName = "";
    otherInventoryHotbarOffset = null;
    otherInventoryHotbarMaxSlots = null;
    isShopInventory = false;
    showContextMenu = false;
    isTradeActive = false;
    selectedItem = null;
    backpack = null;
    backpackData = null;
    isBackpackOpen = false;
    satchelData = null;
    isSatchelOpen = false;
    walletData = null;
    isWalletOpen = false;
    holsterData = null;
    isHolsterOpen = false;
    equipmentSlots = { backpack: null, satchel: null, wallet: null, holster: null };

    try {
      await post("CloseInventory", { name: inventoryName });
      if (currentWasHotbar) {
        toggleHotbar({
          open: true,
          items: hotbarItemsList,
          activeSlots: hotbarActiveList,
        });
      }
    } catch (error) {
      console.error("Error closing inventory:", error);
    }
  }

  async function unequipBackpack() {
    if (busy) return;
    busy = true;
    post("unequipBackpack", {})
      .then(() => {
        closeInventory();
        busy = false;
      })
  }

  function clearTransferAmount() {
    transferAmount = null;
  }

  function getItemInSlot(slot, inventoryType) {
    if (inventoryType === "player") {
      return playerInventory[slot] || null;
    } else if (inventoryType === "other") {
      return otherInventory[slot] || null;
    } else if (inventoryType === "equipment") {
      return equipmentSlots[slot] || null;
    } else if (inventoryType === "satchel") {
      return (satchelData && satchelData.items && satchelData.items[slot]) || null;
    } else if (inventoryType === "backpack") {
      return (backpackData && backpackData.items && backpackData.items[slot]) || null;
    } else if (inventoryType === "wallet") {
      return (walletData && walletData.items && walletData.items[slot]) || null;
    } else if (inventoryType === "holster") {
      return (holsterData && holsterData.items && holsterData.items[slot]) || null;
    }
    return null;
  }

  function showItemInfo(item, type) {
    if (item) {
      if (showContextMenu || currentlyDraggingItem || isMouseDown) return;
      item.inventory = type;
      selectedItem = item;
    }
  }

  function hideItemInfo() {
    selectedItem = null;
  }

  function toggleHotbar(data) {
    if (data.open) {
      hotbarItems = data.items;
      activeHotbarSlots = data.activeSlots || [];
      showHotbar = true;
    } else {
      showHotbar = false;
      hotbarItems = [];
      activeHotbarSlots = [];
    }
  }

  function showItemNotification(itemData) {
    const item = itemData.item || {};
    const rawType = (itemData.type || '').toLowerCase();

    notificationText = item.label || "";
    notificationImage = item.image ? "images/" + item.image : "";

    const typeMap = {
      add: t.received,
      added: t.received,
      receive: t.received,
      use: t.used,
      used: t.used,
      drop: t.removed,
      remove: t.removed,
      removed: t.removed
    };

    notificationType = typeMap[rawType] || t[rawType] || (rawType ? rawType.charAt(0).toUpperCase() + rawType.slice(1) : "");

    notificationClass = (rawType === 'added') ? 'add'
      : (rawType === 'removed') ? 'remove'
      : (rawType === 'use' || rawType === 'used') ? 'use'
      : (rawType === 'drop') ? 'remove'
      : rawType;

    notificationAmount = itemData.amount || 1;
    const desc = item.info?.description || item.description || "";
    notificationDescription = typeof desc === 'string' ? desc : '';
    showNotification = true;

    if (notificationTimeout) {
      clearTimeout(notificationTimeout);
    }

    notificationTimeout = setTimeout(() => {
      showNotification = false;
      notificationDescription = "";
      notificationTimeout = null;
    }, 3000);
  }

  function inventoryError(slot) {
    const slotElement = document.getElementById(`slot-${slot}`);
    if (slotElement) {
      slotElement.style.backgroundColor = "red";
    }
    post("PlayDropFail", {}).catch((error) => {
      console.error("Error playing drop fail:", error);
    });
    setTimeout(() => {
      if (slotElement) {
        slotElement.style.backgroundColor = "";
      }
    }, 1000);
  }

  function copySerial() {
    if (!contextMenuItem) return;
    const item = contextMenuItem;
    if (item && item.info?.serie) {
      const el = document.createElement("textarea");
      el.value = item.info.serie;
      document.body.appendChild(el);
      el.select();
      document.execCommand("copy");
      document.body.removeChild(el);
    }
  }

  // --- Item Interaction Logic ---
  async function useItem(item) {
    if (!item || item.useable === false) return;
    const playerItemKey = Object.keys(playerInventory).find((key) => playerInventory[key] && playerInventory[key].slot === item.slot);
    if (playerItemKey) {
      try {
        if (item.shouldClose) {
          closeInventory();
        }
        await post("UseItem", {
          inventory: "player",
          item: item,
        });
      } catch (error) {
        console.error("Error using the item: ", error);
      }
    }
    showContextMenu = false;
  }

  async function unequipItem(item) {
    if (!item || item.inventory !== 'equipment') return;
    try {
      await post("UnequipItem", {
        equipmentType: item.slot,
      });
    } catch (error) {
      console.error("Error unequipping item: ", error);
    }
    showContextMenu = false;
  }

  async function dropEquipmentItem(item) {
    if (!item || item.inventory !== 'equipment') return;
    try {
      await post("DropEquipmentItem", {
        equipmentType: item.slot,
      });
    } catch (error) {
      console.error("Error dropping equipment item: ", error);
    }
    showContextMenu = false;
  }

  async function giveItem(item, quantity) {
    if (item && item.name) {
      // Detect which inventory the item comes from
      const invType = item.inventory || 'player';
      let sourceInventory = playerInventory;
      let sourceInventoryName = 'player';
      if (invType === 'satchel' && satchelData) {
        sourceInventory = satchelData.items;
        sourceInventoryName = satchelData.uid;
      } else if (invType === 'backpack' && backpackData) {
        sourceInventory = backpackData.items;
        sourceInventoryName = backpackData.uid;
      }

      const itemExists = Object.values(sourceInventory).some((invItem) => invItem && invItem.name === item.name);
      if (itemExists) {
        let amountToGive;
        if (typeof quantity === "string") {
          switch (quantity) {
            case "half":
              amountToGive = Math.ceil(item.amount / 2);
              break;
            case "all":
              amountToGive = item.amount;
              break;
            case "enteramount":
              const amounttt = await post("GiveItemAmount");
              amountToGive = amounttt;
              break;
            default:
              console.error("Invalid quantity specified.");
              return;
          }
        } else {
          amountToGive = quantity;
        }

        if (amountToGive > item.amount) {
          console.error("Specified quantity exceeds available amount.");
          return;
        }

        try {
          const response = await post("GiveItem", {
            item: item,
            amount: amountToGive,
            slot: item.slot,
            info: item.info,
            fromInventory: sourceInventoryName,
          });
          if (!response) return;

          sourceInventory[item.slot].amount -= amountToGive;
          if (sourceInventory[item.slot].amount === 0) {
            delete sourceInventory[item.slot];
          }
        } catch (error) {
          console.error("An error occurred while giving the item:", error);
        }
      }
    }
    showContextMenu = false;
  }

  async function dropItem(item, quantity) {
    if (item && item.name) {
      // Detect which inventory the item comes from
      const invType = item.inventory || 'player';
      let sourceInventory = playerInventory;
      let sourceInventoryName = 'player';
      if (invType === 'satchel' && satchelData) {
        sourceInventory = satchelData.items;
        sourceInventoryName = satchelData.uid;
      } else if (invType === 'backpack' && backpackData) {
        sourceInventory = backpackData.items;
        sourceInventoryName = backpackData.uid;
      }

      const itemKey = Object.keys(sourceInventory).find((key) =>
        sourceInventory[key] && sourceInventory[key].slot === item.slot
      );

      if (itemKey) {
        let amountToGive;
        if (typeof quantity === "string") {
          switch (quantity) {
            case "half":
              amountToGive = Math.ceil(item.amount / 2);
              break;
            case "all":
              amountToGive = item.amount;
              break;
            case "enteramount":
              const amounttt = await post("GiveItemAmount");
              amountToGive = amounttt;
              break;
            default:
              console.error("Invalid quantity specified.");
              return;
          }
        } else if (typeof quantity === "number" && quantity > 0) {
          amountToGive = quantity;
        }

        if (amountToGive > item.amount) {
          amountToGive = item.amount;
        }

        const newItem = {
          ...item,
          amount: amountToGive,
          slot: 1,
          inventory: "other",
        };

        try {
          const response = await post("DropItem", {
            ...newItem,
            fromSlot: item.slot,
            fromInventory: sourceInventoryName,
          });

          if (response) {
            const remainingAmount = sourceInventory[itemKey].amount - amountToGive;
            if (remainingAmount <= 0) {
              delete sourceInventory[itemKey];
            } else {
              sourceInventory[itemKey].amount = remainingAmount;
            }

            otherInventory[1] = newItem;
            otherInventoryName = response;
            otherInventoryLabel = response;
            isOtherInventoryEmpty = false;
          }
        } catch (error) {
          inventoryError(item.slot);
        }
      }
    }
    showContextMenu = false;
  }

  async function splitAndPlaceItem(item, inventoryType, splitamount = 'half') {
    const inventoryRef = inventoryType === "player" ? playerInventory : otherInventory;
    let amount = 1;
    if (item && item.amount > 1) {
      if (splitamount === 'half') {
        amount = Math.ceil(item.amount / 2);
      } else if (splitamount === 'enteramount') {
        const inputAmount = await post("GiveItemAmount");
        amount = inputAmount;
        if (amount < 1) amount = 1;
        if (amount > item.amount) amount = item.amount;
      } else if (typeof splitamount === 'number') {
        amount = splitamount;
      }

      const originalSlot = Object.keys(inventoryRef).find((key) => inventoryRef[key] === item);
      if (originalSlot !== undefined) {
        const newItem = { ...item, amount: amount };
        const nextSlot = findNextAvailableSlot(inventoryRef);
        if (nextSlot !== null) {
          const backupInventory = JSON.parse(JSON.stringify(inventoryRef));
          inventoryRef[nextSlot] = newItem;
          inventoryRef[originalSlot] = { ...item, amount: item.amount - amount };
          const success = await postInventoryData(inventoryType, inventoryType, originalSlot, nextSlot, item.amount, newItem.amount);
          if (!success) {
            restoreInventory(inventoryType, backupInventory);
            inventoryError(originalSlot);
          }
        }
      }
    }
    showContextMenu = false;
  }

  function findNextAvailableSlot(inventory) {
    for (let slot = 1; slot <= totalSlots; slot++) {
      if (!inventory[slot]) {
        return slot;
      }
    }
    return null;
  }

  function restoreInventory(type, backupState) {
    if (type === "player") {
      playerInventory = backupState;
    } else if (type === "other") {
      otherInventory = backupState;
    } else if (type === "backpack" && backpackData) {
      backpackData.items = backupState;
    } else if (type === "satchel" && satchelData) {
      satchelData.items = backupState;
    } else if (type === "wallet" && walletData) {
      walletData.items = backupState;
    } else if (type === "holster" && holsterData) {
      holsterData.items = backupState;
    }
  }

  async function postInventoryData(fromInventory, toInventory, fromSlot, toSlot, fromAmount, toAmount) {
    busy = true;
    let fromInventoryName = fromInventory === "other" ? otherInventoryName 
      : (fromInventory === "backpack" && backpackData ? backpackData.uid 
        : (fromInventory === "satchel" && satchelData ? satchelData.uid 
          : (fromInventory === "wallet" && walletData ? walletData.uid 
            : (fromInventory === "holster" && holsterData ? holsterData.uid : fromInventory))));

    let toInventoryName = toInventory === "other" ? otherInventoryName 
      : (toInventory === "backpack" && backpackData ? backpackData.uid 
        : (toInventory === "satchel" && satchelData ? satchelData.uid 
          : (toInventory === "wallet" && walletData ? walletData.uid 
            : (toInventory === "holster" && holsterData ? holsterData.uid : toInventory))));

    try {
      const response = await post("SetInventoryData", {
        fromInventory: fromInventoryName,
        toInventory: toInventoryName,
        fromSlot,
        toSlot,
        fromAmount,
        toAmount,
      });
      clearDragData();
      busy = false;
      return response && response.success;
    } catch (error) {
      console.error("Error posting inventory data:", error);
      clearDragData();
      busy = false;
      return false;
    }
  }

  async function moveItemBetweenInventories(item, sourceInventoryType) {
    if (busy) return;
    busy = true;
    const sourceInventory = sourceInventoryType === "player" ? playerInventory : otherInventory;
    const targetInventory = sourceInventoryType === "player" ? otherInventory : playerInventory;
    const amountToTransfer = transferAmount !== null ? transferAmount : 1;
    let targetSlot = null;

    const sourceItem = sourceInventory[item.slot];
    if (!sourceItem || sourceItem.amount < amountToTransfer) {
      inventoryError(item.slot);
      busy = false;
      return;
    }

    const totalWeightAfterTransfer = otherInventoryWeight + sourceItem.weight * amountToTransfer;
    if (totalWeightAfterTransfer > otherInventoryMaxWeight) {
      inventoryError(item.slot);
      busy = false;
      return;
    }

    if (playerInventory !== targetInventory) {
      if (findNextAvailableSlot(targetInventory) > otherInventorySlots) {
        inventoryError(item.slot);
        busy = false;
        return;
      }
    }

    // Save backup snapshots
    const backupSource = JSON.parse(JSON.stringify(sourceInventory));
    const backupTarget = JSON.parse(JSON.stringify(targetInventory));

    if (item.unique) {
      targetSlot = findNextAvailableSlot(targetInventory);
      if (targetSlot === null) {
        inventoryError(item.slot);
        busy = false;
        return;
      }

      const newItem = {
        ...item,
        inventory: sourceInventoryType === "player" ? "other" : "player",
        amount: amountToTransfer,
      };
      targetInventory[targetSlot] = newItem;
      newItem.slot = targetSlot;
    } else {
      const targetItemKey = Object.keys(targetInventory).find((key) => 
        targetInventory[key] && targetInventory[key].name === item.name && targetInventory[key].info.quality === item.info.quality
      );
      const targetItem = targetInventory[targetItemKey];

      if (!targetItem) {
        const newItem = {
          ...item,
          inventory: sourceInventoryType === "player" ? "other" : "player",
          amount: amountToTransfer,
        };

        targetSlot = findNextAvailableSlot(targetInventory);
        if (targetSlot === null) {
          inventoryError(item.slot);
          busy = false;
          return;
        }

        targetInventory[targetSlot] = newItem;
        newItem.slot = targetSlot;
      } else {
        targetItem.amount += amountToTransfer;
        targetSlot = targetItem.slot;
      }
    }

    sourceItem.amount -= amountToTransfer;
    if (sourceItem.amount <= 0) {
      delete sourceInventory[item.slot];
    }

    const success = await postInventoryData(sourceInventoryType, sourceInventoryType === "player" ? "other" : "player", item.slot, targetSlot, sourceItem.amount, amountToTransfer);
    if (!success) {
      restoreInventory(sourceInventoryType, backupSource);
      restoreInventory(sourceInventoryType === "player" ? "other" : "player", backupTarget);
      inventoryError(item.slot);
    }
  }

  // --- Drag & Drop Core Handlers ---
  function handleMouseDown(event, slot, inventory) {
    if (event.button === 1) return;
    event.preventDefault();
    const itemInSlot = getItemInSlot(slot, inventory);
    if (event.button === 0) {
      if (event.shiftKey && itemInSlot) {
        splitAndPlaceItem(itemInSlot, inventory);
      } else {
        isMouseDown = true;
        mouseDownX = event.clientX;
        mouseDownY = event.clientY;
        currentlyDraggingSlot = slot;
        dragStartInventoryType = inventory;
        currentlyDraggingItem = itemInSlot;
        dragStartEquipmentType = inventory === "equipment" ? slot : null;
      }
    } else if (event.button === 2 && itemInSlot) {
      if (isShopInventory && inventory === "other") {
        handlePurchase(itemInSlot.slot, itemInSlot, 1, inventory);
        return;
      }
      if (!isOtherInventoryEmpty && inventory !== 'satchel' && inventory !== 'backpack' && inventory !== 'wallet' && inventory !== 'holster') {
        moveItemBetweenInventories(itemInSlot, inventory);
      } else {
        showContextMenuOptions(event, itemInSlot);
      }
    }
  }

  function handleMouseMove(event) {
    if (isMouseDown && !isDragging && currentlyDraggingItem) {
      const dx = Math.abs(event.clientX - mouseDownX);
      const dy = Math.abs(event.clientY - mouseDownY);
      if (dx >= dragThreshold || dy >= dragThreshold) {
        isDragging = true;
        hideItemInfo();
      }
    }

    if (isDragging) {
      dragX = event.clientX - 35; // centered relative offset
      dragY = event.clientY - 35;
    }
  }

  function handleMouseUp(event) {
    if (isMouseDown) {
      isMouseDown = false;
      if (isDragging && currentlyDraggingItem) {
        isDragging = false;

        const targetEquipmentSlotElement = event.target.closest(".equipment-inventory .item-slot");
        if (targetEquipmentSlotElement) {
          const equipmentType = targetEquipmentSlotElement.dataset.slot;
          if (equipmentType && dragStartInventoryType === "player") {
            handleDropOnEquipmentSlot(equipmentType);
          }
        }

        const targetPlayerItemSlotElement = event.target.closest(".player-inventory .item-slot");
        if (targetPlayerItemSlotElement) {
          const targetSlot = Number(targetPlayerItemSlotElement.dataset.slot);
          if (targetSlot) {
            if (dragStartInventoryType === "equipment") {
              handleDropFromEquipmentSlot(targetSlot);
            } else if (!(targetSlot === currentlyDraggingSlot && dragStartInventoryType === "player")) {
              handleDropOnPlayerSlot(targetSlot);
            }
          }
        }

        const targetSecondaryItemSlotElement = event.target.closest(".other-inventory .item-slot, .satchel-inventory .item-slot, .backpack-inventory .item-slot, .wallet-inventory .item-slot, .holster-inventory .item-slot");
        if (targetSecondaryItemSlotElement && dragStartInventoryType !== "equipment") {
          const targetSlot = Number(targetSecondaryItemSlotElement.dataset.slot);
          const isSatchelDrop = !!targetSecondaryItemSlotElement.closest(".satchel-inventory");
          const isBackpackDrop = !!targetSecondaryItemSlotElement.closest(".backpack-inventory");
          const isWalletDrop = !!targetSecondaryItemSlotElement.closest(".wallet-inventory");
          const isHolsterDrop = !!targetSecondaryItemSlotElement.closest(".holster-inventory");
          const targetInvType = isSatchelDrop ? "satchel" : (isBackpackDrop ? "backpack" : (isWalletDrop ? "wallet" : (isHolsterDrop ? "holster" : "other")));

          if (targetSlot && !(targetSlot === currentlyDraggingSlot && dragStartInventoryType === targetInvType)) {
            handleItemDrop(targetInvType, targetSlot);
          }
        }

        const targetTradeContainer = event.target.closest(".trade-container, .trade-panel, .trade-items");
        if (targetTradeContainer && dragStartInventoryType === "player" && isTradeActive) {
          const amount = transferAmount !== null ? transferAmount : currentlyDraggingItem.amount;
          addItemToTrade(currentlyDraggingItem, amount);
        } else {
          const targetInventoryContainer = event.target.closest(".inventory-container");
          if (targetInventoryContainer && !targetPlayerItemSlotElement && !targetSecondaryItemSlotElement && !targetEquipmentSlotElement) {
            handleDropOnInventoryContainer();
          }
        }
      }
      clearDragData();
    }
  }

  function handleDropOnEquipmentSlot(equipmentType) {
    if (isShopInventory) return;
    post("EquipItem", { slot: currentlyDraggingSlot, equipmentType: equipmentType });
  }

  function handleDropFromEquipmentSlot(targetSlot) {
    post("UnequipItem", { equipmentType: dragStartEquipmentType, slot: targetSlot });
  }

  function handleDropOnPlayerSlot(targetSlot) {
    if (isShopInventory && dragStartInventoryType === "other") {
      const targetInventory = playerInventory;
      const targetItem = targetInventory[targetSlot];
      if ((targetItem && targetItem.name !== currentlyDraggingItem.name)
        || (targetItem && targetItem.name === currentlyDraggingItem.name && currentlyDraggingItem.unique)
        || (targetItem && targetItem.name === currentlyDraggingItem.name && targetItem.info && typeof targetItem.info === 'object' && targetItem.info.quality && targetItem.info.quality !== 100)) {
        inventoryError(currentlyDraggingSlot);
        return;
      }
      handlePurchase(currentlyDraggingSlot, currentlyDraggingItem, transferAmount, dragStartInventoryType, targetSlot);
    } else {
      handleItemDrop("player", targetSlot);
    }
  }

  function handleDropOnOtherSlot(targetSlot) {
    handleItemDrop("other", targetSlot);
  }

  async function handleDropOnInventoryContainer() {
    if (isOtherInventoryEmpty && dragStartInventoryType === "player") {
      const newItem = {
        ...currentlyDraggingItem,
        amount: currentlyDraggingItem.amount,
        slot: 1,
        inventory: "other",
      };
      const draggingItem = currentlyDraggingItem;
      try {
        const response = await post("DropItem", {
          ...newItem,
          fromSlot: currentlyDraggingSlot,
        });

        if (response) {
          otherInventory[1] = newItem;
          const draggingItemKey = Object.keys(playerInventory).find((key) => playerInventory[key] === draggingItem);
          if (draggingItemKey) {
            delete playerInventory[draggingItemKey];
          }
          otherInventoryName = response;
          otherInventoryLabel = response;
          isOtherInventoryEmpty = false;
          clearDragData();
        }
      } catch (error) {
        inventoryError(currentlyDraggingSlot);
      }
    }
    clearDragData();
  }

  async function handleItemDrop(targetInventoryType, targetSlot) {
    try {
      const isShop = otherInventoryName.indexOf("shop-");
      if (dragStartInventoryType === "other" && targetInventoryType === "other" && isShop !== -1) {
        return;
      }

      const targetSlotNumber = parseInt(targetSlot, 10);
      if (isNaN(targetSlotNumber)) return;

      const sourceInventory = dragStartInventoryType === "player"
        ? playerInventory
        : (dragStartInventoryType === "backpack" && backpackData
          ? backpackData.items
          : (dragStartInventoryType === "satchel" && satchelData
            ? satchelData.items
            : (dragStartInventoryType === "wallet" && walletData
              ? walletData.items
              : (dragStartInventoryType === "holster" && holsterData
                ? holsterData.items
                : otherInventory))));
      
      const targetInventory = targetInventoryType === "player"
        ? playerInventory
        : (targetInventoryType === "backpack" && backpackData
          ? backpackData.items
          : (targetInventoryType === "satchel" && satchelData
            ? satchelData.items
            : (targetInventoryType === "wallet" && walletData
              ? walletData.items
              : (targetInventoryType === "holster" && holsterData
                ? holsterData.items
                : otherInventory))));

      const sourceItem = sourceInventory[currentlyDraggingSlot];
      if (!sourceItem) return;

      const amountToTransfer = transferAmount !== null ? transferAmount : sourceItem.amount;
      if (sourceItem.amount < amountToTransfer) return;

      // Check wallet restriction (only accepts cash/money items)
      if (targetInventoryType === "wallet") {
        const allowed = ["cash", "money", "dollar", "cent", "blood_dollar", "blood_cent", "gold_bar", "gold_chunk"].includes(sourceItem.name) 
          || sourceItem.name.includes("money") 
          || sourceItem.name.includes("cash") 
          || sourceItem.name.includes("dollar") 
          || sourceItem.name.includes("cent");
        if (!allowed) {
          inventoryError(currentlyDraggingSlot);
          return;
        }
      }

      // Check holster restriction (only accepts weapons and ammo)
      if (targetInventoryType === "holster") {
        const isWeapon = sourceItem.type === "weapon" || sourceItem.name.startsWith("weapon_");
        const isAmmo = sourceItem.type === "ammo" || sourceItem.name.startsWith("ammo_") || sourceItem.name.includes("ammo");
        if (!isWeapon && !isAmmo) {
          inventoryError(currentlyDraggingSlot);
          return;
        }
      }

      if (dragStartInventoryType === "player" && targetInventoryType === "other" && isShop !== -1) {
        handlePurchase(
          currentlyDraggingSlot,
          sourceItem,
          transferAmount !== null ? transferAmount : sourceItem.amount,
          dragStartInventoryType
        );
        return;
      }

      if (targetInventoryType !== dragStartInventoryType) {
        if (targetInventoryType === "other") {
          const totalWeightAfterTransfer = otherInventoryWeight + sourceItem.weight * amountToTransfer;
          if (totalWeightAfterTransfer > otherInventoryMaxWeight) {
            throw new Error("Weight capacity exceeded");
          }
        } else if (targetInventoryType === "player") {
          const totalWeightAfterTransfer = playerWeight + sourceItem.weight * amountToTransfer;
          if (totalWeightAfterTransfer > maxWeight) {
            throw new Error("Weight capacity exceeded");
          }
        } else if (targetInventoryType === "backpack" && backpackData) {
          const currentBackpackWeight = Object.values(backpackData.items).reduce((acc, it) => acc + (it ? (it.weight * it.amount) : 0), 0);
          const totalWeightAfterTransfer = currentBackpackWeight + sourceItem.weight * amountToTransfer;
          if (totalWeightAfterTransfer > backpackData.maxweight) {
            throw new Error("Weight capacity exceeded");
          }
        } else if (targetInventoryType === "satchel" && satchelData) {
          const currentSatchelWeight = Object.values(satchelData.items).reduce((acc, it) => acc + (it ? (it.weight * it.amount) : 0), 0);
          const totalWeightAfterTransfer = currentSatchelWeight + sourceItem.weight * amountToTransfer;
          if (totalWeightAfterTransfer > satchelData.maxweight) {
            throw new Error("Weight capacity exceeded");
          }
        } else if (targetInventoryType === "wallet" && walletData) {
          const currentWalletWeight = Object.values(walletData.items).reduce((acc, it) => acc + (it ? (it.weight * it.amount) : 0), 0);
          const totalWeightAfterTransfer = currentWalletWeight + sourceItem.weight * amountToTransfer;
          if (totalWeightAfterTransfer > walletData.maxweight) {
            throw new Error("Weight capacity exceeded");
          }
        } else if (targetInventoryType === "holster" && holsterData) {
          const currentHolsterWeight = Object.values(holsterData.items).reduce((acc, it) => acc + (it ? (it.weight * it.amount) : 0), 0);
          const totalWeightAfterTransfer = currentHolsterWeight + sourceItem.weight * amountToTransfer;
          if (totalWeightAfterTransfer > holsterData.maxweight) {
            throw new Error("Weight capacity exceeded");
          }
        }
      }

      // Save backup snapshots
      const backupSource = JSON.parse(JSON.stringify(sourceInventory));
      const backupTarget = JSON.parse(JSON.stringify(targetInventory));

      const targetItem = targetInventory[targetSlotNumber];

      if (targetItem) {
        if (sourceItem.name === targetItem.name && targetItem.unique) {
          inventoryError(currentlyDraggingSlot);
          return;
        }
        const sourceQuality = (sourceItem.info && typeof sourceItem.info === 'object') ? sourceItem.info.quality : null;
        const targetQuality = (targetItem.info && typeof targetItem.info === 'object') ? targetItem.info.quality : null;
        if (sourceItem.name === targetItem.name && !targetItem.unique && sourceQuality === targetQuality) {
          targetItem.amount += amountToTransfer;
          sourceItem.amount -= amountToTransfer;
          if (sourceItem.amount <= 0) {
            delete sourceInventory[currentlyDraggingSlot];
          }
          const success = await postInventoryData(dragStartInventoryType, targetInventoryType, currentlyDraggingSlot, targetSlotNumber, sourceItem.amount, amountToTransfer);
          if (!success) {
            restoreInventory(dragStartInventoryType, backupSource);
            restoreInventory(targetInventoryType, backupTarget);
            inventoryError(currentlyDraggingSlot);
          }
        } else {
          sourceInventory[currentlyDraggingSlot] = targetItem;
          targetInventory[targetSlotNumber] = sourceItem;
          sourceInventory[currentlyDraggingSlot].slot = currentlyDraggingSlot;
          sourceInventory[currentlyDraggingSlot].inventory = dragStartInventoryType;
          targetInventory[targetSlotNumber].slot = targetSlotNumber;
          targetInventory[targetSlotNumber].inventory = targetInventoryType;
          const success = await postInventoryData(dragStartInventoryType, targetInventoryType, currentlyDraggingSlot, targetSlotNumber, sourceItem.amount, targetItem.amount);
          if (!success) {
            restoreInventory(dragStartInventoryType, backupSource);
            restoreInventory(targetInventoryType, backupTarget);
            inventoryError(currentlyDraggingSlot);
          }
        }
      } else {
        sourceItem.amount -= amountToTransfer;
        if (sourceItem.amount <= 0) {
          delete sourceInventory[currentlyDraggingSlot];
        }
        targetInventory[targetSlotNumber] = { ...sourceItem, amount: amountToTransfer, slot: targetSlotNumber, inventory: targetInventoryType };
        const success = await postInventoryData(dragStartInventoryType, targetInventoryType, currentlyDraggingSlot, targetSlotNumber, sourceItem.amount, amountToTransfer);
        if (!success) {
          restoreInventory(dragStartInventoryType, backupSource);
          restoreInventory(targetInventoryType, backupTarget);
          inventoryError(currentlyDraggingSlot);
        }
      }
    } catch (error) {
      console.error(error);
      inventoryError(currentlyDraggingSlot);
    } finally {
      clearDragData();
    }
  }

  async function handlePurchase(sourceSlot, sourceItem, transferAmt, sourceInventoryType, targetSlot = null) {
    if (busy) return;
    if (sourceItem.amount < 1) {
      inventoryError(sourceSlot);
      return;
    }

    busy = true;
    try {
      const response = await post("AttemptPurchase", {
        item: sourceItem,
        amount: transferAmt || 1,
        shop: otherInventoryName,
        sourceinvtype: sourceInventoryType,
        targetslot: targetSlot,
      });

      if (response) {
        if (!sourceItem.amount) {
          busy = false;
          return;
        }

        const amountToTransfer = transferAmt !== null ? transferAmt : 1;
        if (sourceInventoryType === 'player') {
          for (const key in otherInventory) {
            const item = otherInventory[key];
            if (item.name === sourceItem.name && item.amount !== undefined) {
              otherInventory[key].amount += amountToTransfer;
              break;
            }
          }
        } else {
          if (sourceItem.amount < amountToTransfer) {
            inventoryError(sourceSlot);
            busy = false;
            return;
          }
          sourceItem.amount -= amountToTransfer;
        }
      } else {
        inventoryError(sourceSlot);
      }
    } catch (error) {
      inventoryError(sourceSlot);
    } finally {
      busy = false;
    }
  }

  function clearDragData() {
    currentlyDraggingItem = null;
    currentlyDraggingSlot = null;
    isDragging = false;
    dragStartEquipmentType = null;
  }

  // --- Trade UI Action Wrappers ---
  function openTrade(data) {
    isInventoryOpen = true;
    maxWeight = data.maxweight || 0;
    totalSlots = data.slots || 0;
    playerId = data.playerId || null;
    playerName = data.playerName || null;
    cash = data.cash || 0;
    playerInventory = {};
    otherInventory = {};
    isOtherInventoryEmpty = true;

    if (data.labels) {
      t = { ...t, ...data.labels };
    }

    if (data.inventory) {
      if (Array.isArray(data.inventory)) {
        data.inventory.forEach((item) => {
          if (item && item.slot) {
            item.inventory = "player";
            playerInventory[item.slot] = item;
          }
        });
      } else if (typeof data.inventory === "object") {
        for (const key in data.inventory) {
          const item = data.inventory[key];
          if (item && item.slot) {
            item.inventory = "player";
            playerInventory[item.slot] = item;
          }
        }
      }
    }

    tradeId = data.tradeId;
    tradePartnerName = data.partnerName;
    myTradeOffers = {};
    theirTradeOffers = {};
    myTradeAccepted = false;
    theirTradeAccepted = false;
    isTradeActive = true;
  }

  function updateTrade(data) {
    const tradeData = data.tradeData;
    const myId = Number(playerId);
    const isInitiator = Number(tradeData.initiator) === myId;
    myTradeAccepted = isInitiator ? tradeData.initiatorAccepted : tradeData.targetAccepted;
    theirTradeAccepted = isInitiator ? tradeData.targetAccepted : tradeData.initiatorAccepted;
    myTradeOffers = isInitiator ? tradeData.initiatorItems : tradeData.targetItems;
    theirTradeOffers = isInitiator ? tradeData.targetItems : tradeData.initiatorItems;
  }

  function cancelTradeUI() {
    isTradeActive = false;
    tradeId = null;
    tradePartnerName = null;
    myTradeOffers = {};
    theirTradeOffers = {};
    myTradeAccepted = false;
    theirTradeAccepted = false;
  }

  function completeTradeUI() {
    cancelTradeUI();
    closeInventory();
  }

  function addItemToTrade(item, amount) {
    if (!isTradeActive || !tradeId) return;
    const amountToAdd = amount !== undefined ? amount : item.amount;
    if (amountToAdd < 1 || amountToAdd > item.amount) return;
    post("AddTradeItem", {
      tradeId: tradeId,
      item: item,
      amount: amountToAdd,
    }).catch((error) => {
      console.error("Error adding item to trade:", error);
    });
    showContextMenu = false;
  }

  async function addItemToTradeWithPrompt(item) {
    if (!isTradeActive || !tradeId) return;
    try {
      const amount = await post("GiveItemAmount");
      if (amount && amount > 0 && amount <= item.amount) {
        addItemToTrade(item, amount);
      }
    } catch (error) {
      console.error("Error getting trade amount:", error);
    }
    showContextMenu = false;
  }

  function removeItemFromTrade(tradeSlot) {
    if (!isTradeActive || !tradeId) return;
    post("RemoveTradeItem", {
      tradeId: tradeId,
      tradeSlot: tradeSlot,
    }).catch((error) => {
      console.error("Error removing item from trade:", error);
    });
  }

  function confirmTrade() {
    if (!isTradeActive || !tradeId) return;
    post("ConfirmTrade", { tradeId: tradeId }).catch((error) => {
      console.error("Error confirming trade:", error);
    });
  }

  function cancelTrade() {
    if (!isTradeActive || !tradeId) return;
    post("CancelTrade", { tradeId: tradeId }).catch((error) => {
      console.error("Error cancelling trade:", error);
    });
  }

  async function handleEquipmentClick(equipType) {
    if (busy) return;
    const item = equipmentSlots[equipType];
    if (!item) return;

    let rawUid = item.info && (item.info.stashId || item.info.uid);
    if (!rawUid) return;
    const uid = rawUid.startsWith("bp_") ? rawUid : "bp_" + rawUid;

    if (equipType === 'satchel') {
      if (isSatchelOpen) {
        isSatchelOpen = false;
        satchelData = null;
      } else {
        try {
          const data = await post("GetBackpackStashData", { uid: uid, model: item.name || item.itemName });
          if (data) {
            const itemsMap = {};
            const itemsList = Array.isArray(data.items) ? data.items : Object.values(data.items || {});
            itemsList.forEach((it) => {
              if (it && it.slot) {
                it.inventory = "satchel";
                itemsMap[it.slot] = it;
              }
            });
            satchelData = { ...data, items: itemsMap, uid: uid };
            isSatchelOpen = true;
            isBackpackOpen = false;
            isWalletOpen = false;
            isHolsterOpen = false;
          }
        } catch (err) {
          console.error("Error opening satchel:", err);
        }
      }
    } else if (equipType === 'wallet') {
      if (isWalletOpen) {
        isWalletOpen = false;
        walletData = null;
      } else {
        try {
          const data = await post("GetBackpackStashData", { uid: uid, model: item.name || item.itemName });
          if (data) {
            const itemsMap = {};
            const itemsList = Array.isArray(data.items) ? data.items : Object.values(data.items || {});
            itemsList.forEach((it) => {
              if (it && it.slot) {
                it.inventory = "wallet";
                itemsMap[it.slot] = it;
              }
            });
            walletData = { ...data, items: itemsMap, uid: uid };
            isWalletOpen = true;
            isSatchelOpen = false;
            isBackpackOpen = false;
            isHolsterOpen = false;
          }
        } catch (err) {
          console.error("Error opening wallet:", err);
        }
      }
    } else if (equipType === 'holster') {
      if (isHolsterOpen) {
        isHolsterOpen = false;
        holsterData = null;
      } else {
        try {
          const data = await post("GetBackpackStashData", { uid: uid, model: item.name || item.itemName });
          if (data) {
            const itemsMap = {};
            const itemsList = Array.isArray(data.items) ? data.items : Object.values(data.items || {});
            itemsList.forEach((it) => {
              if (it && it.slot) {
                it.inventory = "holster";
                itemsMap[it.slot] = it;
              }
            });
            holsterData = { ...data, items: itemsMap, uid: uid };
            isHolsterOpen = true;
            isSatchelOpen = false;
            isBackpackOpen = false;
            isWalletOpen = false;
          }
        } catch (err) {
          console.error("Error opening holster:", err);
        }
      }
    }
  }

  async function searchBackpack(item) {
    const nameVal = item ? (item.name || item.itemName || '') : '';
    if (item && (nameVal.startsWith("backpack_") || nameVal.startsWith("satchel_") || nameVal.startsWith("wallet_") || nameVal.startsWith("holster_")) && item.info) {
      let rawUid = item.info.stashId || item.info.uid;
      if (!rawUid) return;
      const uid = rawUid.startsWith("bp_") ? rawUid : "bp_" + rawUid;
        try {
          const data = await post("GetBackpackStashData", { uid: uid, model: nameVal });
          if (data) {
            const itemsMap = {};
            const isSatchel = nameVal.startsWith("satchel_");
            const isWallet = nameVal.startsWith("wallet_");
            const isHolster = nameVal.startsWith("holster_");
            const invType = isSatchel ? "satchel" : (isWallet ? "wallet" : (isHolster ? "holster" : "backpack"));
            
            if (Array.isArray(data.items)) {
              data.items.forEach((it) => {
                if (it && it.slot) {
                  it.inventory = invType;
                  itemsMap[it.slot] = it;
                }
              });
            } else if (typeof data.items === "object") {
              for (const key in data.items) {
                const it = data.items[key];
                if (it && it.slot) {
                  it.inventory = invType;
                  itemsMap[it.slot] = it;
                }
              }
            }
            
            if (isSatchel) {
              satchelData = { ...data, items: itemsMap, uid: uid };
              isSatchelOpen = true;
              isBackpackOpen = false;
              isWalletOpen = false;
              isHolsterOpen = false;
            } else if (isWallet) {
              walletData = { ...data, items: itemsMap, uid: uid };
              isWalletOpen = true;
              isSatchelOpen = false;
              isBackpackOpen = false;
              isHolsterOpen = false;
            } else if (isHolster) {
              holsterData = { ...data, items: itemsMap, uid: uid };
              isHolsterOpen = true;
              isSatchelOpen = false;
              isBackpackOpen = false;
              isWalletOpen = false;
            } else {
              backpackData = { ...data, items: itemsMap, uid: uid };
              isBackpackOpen = true;
              isSatchelOpen = false;
              isWalletOpen = false;
              isHolsterOpen = false;
            }
          }
        } catch (error) {
          console.error("Error searching container:", error);
        }
      }
    showContextMenu = false;
  }

  function showContextMenuOptions(event, item) {
    event.preventDefault();
    logDebug("[NUI App.svelte] showContextMenuOptions item: " + JSON.stringify(item));
    if (contextMenuItem && contextMenuItem.name === item.name && showContextMenu) {
      showContextMenu = false;
      contextMenuItem = null;
    } else {
      hideItemInfo();
      const menuLeft = event.clientX;
      const menuTop = event.clientY;
      showContextMenu = true;
      contextMenuPosition = {
        top: `${menuTop}px`,
        left: `${menuLeft}px`,
      };
      contextMenuItem = item;
    }
  }

  // --- NUI Message Handler ---
  const handleMessage = async (event) => {
    if (event.data.invToken) {
      nuiToken = event.data.invToken;
      window.nuiToken = event.data.invToken;
    }

    switch (event.data.action) {
      case "open":
        const valid = await validateToken(event.data.token);
        if (valid) openInventory(event.data);
        break;
      case "close":
        closeInventory();
        break;
      case "update":
        if (await validateToken(event.data.token)) {
          updateInventory(event.data);
        }
        break;
      case "toggleHotbar":
        if (await validateToken(event.data.token)) {
          toggleHotbar(event.data);
        }
        break;
      case "itemBox":
        if (event.data.labels) {
          t = { ...t, ...event.data.labels };
        }
        showItemNotification(event.data);
        break;
        case "updateHotbar":
          if (await validateToken(event.data.token)) {
            hotbarItems = event.data.items;
            if (event.data.activeSlots) {
              activeHotbarSlots = event.data.activeSlots;
            }
          }
          break;
      case "openTrade":
        if (await validateToken(event.data.token)) {
          openTrade(event.data);
        }
        break;
      case "updateTrade":
        if (await validateToken(event.data.token)) {
          updateTrade(event.data);
        }
        break;
      case "cancelTrade":
        if (await validateToken(event.data.token)) {
          cancelTradeUI();
        }
        break;
      case "completeTrade":
        if (await validateToken(event.data.token)) {
          completeTradeUI();
        }
        break;
    }
  };

  const handleKeyUp = (event) => {
    const code = event.code;
    if (code === "Escape" || code === "Tab" || code === "KeyI") {
      if (isInventoryOpen) closeInventory();
    }
  };

  onMount(() => {
    window.addEventListener("message", handleMessage);
    window.addEventListener("keyup", handleKeyUp);
  });

  onDestroy(() => {
    window.removeEventListener("message", handleMessage);
    window.removeEventListener("keyup", handleKeyUp);
  });
</script>

<svelte:window 
  onmousemove={handleMouseMove}
  onmouseup={handleMouseUp}
/>

{#if isInventoryOpen}
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <div class="inventory-container" onclick={() => { showContextMenu = false; hideItemInfo(); }}>
    
    <!-- Satchel (Esquerdo) -->
    {#if isSatchelOpen && satchelData}
      <InventoryPanel
        inventoryType="satchel"
        inventoryLabel={satchelData.label || t.satchel}
        inventoryWeight={(satchelData.items ? Object.values(satchelData.items).reduce((acc, it) => acc + (it ? (it.weight * it.amount) : 0), 0) : 0)}
        inventoryMaxWeight={satchelData.maxweight}
        inventorySlots={satchelData.slots}
        inventoryItems={satchelData.items}
        isShopInventory={false}
        shouldCenterInventory={false}
        t={t}
        playerMoney={0}
        getItemInSlot={getItemInSlot}
        useItem={useItem}
        handleMouseDown={handleMouseDown}
        showItemInfo={showItemInfo}
        hideItemInfo={hideItemInfo}
        selectedItem={selectedItem}
        showContextMenu={showContextMenu}
        errorSlot={errorSlot}
        hotbarOffset={2}
        hotbarMaxSlots={2}
      />
    {/if}

    <!-- Backpack (Direito) -->
    {#if isBackpackOpen && backpackData}
      <InventoryPanel
        inventoryType="backpack"
        inventoryLabel={backpackData.label || "Mochila"}
        inventoryWeight={(backpackData.items ? Object.values(backpackData.items).reduce((acc, it) => acc + (it ? (it.weight * it.amount) : 0), 0) : 0)}
        inventoryMaxWeight={backpackData.maxweight}
        inventorySlots={backpackData.slots}
        inventoryItems={backpackData.items}
        isShopInventory={false}
        shouldCenterInventory={false}
        t={t}
        playerMoney={0}
        getItemInSlot={getItemInSlot}
        useItem={useItem}
        handleMouseDown={handleMouseDown}
        showItemInfo={showItemInfo}
        hideItemInfo={hideItemInfo}
        selectedItem={selectedItem}
        showContextMenu={showContextMenu}
        errorSlot={errorSlot}
        hasOtherInventory={!isOtherInventoryEmpty}
      />
    {/if}

    <!-- Wallet (Esquerdo) -->
    {#if isWalletOpen && walletData}
      <InventoryPanel
        inventoryType="wallet"
        inventoryLabel={walletData.label || "CARTEIRA"}
        inventoryWeight={(walletData.items ? Object.values(walletData.items).reduce((acc, it) => acc + (it ? (it.weight * it.amount) : 0), 0) : 0)}
        inventoryMaxWeight={walletData.maxweight}
        inventorySlots={walletData.slots}
        inventoryItems={walletData.items}
        isShopInventory={false}
        shouldCenterInventory={false}
        t={t}
        playerMoney={0}
        getItemInSlot={getItemInSlot}
        useItem={useItem}
        handleMouseDown={handleMouseDown}
        showItemInfo={showItemInfo}
        hideItemInfo={hideItemInfo}
        selectedItem={selectedItem}
        showContextMenu={showContextMenu}
        errorSlot={errorSlot}
        hotbarOffset={4}
        hotbarMaxSlots={1}
      />
    {/if}

    <!-- Holster (Direito) -->
    {#if isHolsterOpen && holsterData}
      <InventoryPanel
        inventoryType="holster"
        inventoryLabel={holsterData.label || "CINTO"}
        inventoryWeight={(holsterData.items ? Object.values(holsterData.items).reduce((acc, it) => acc + (it ? (it.weight * it.amount) : 0), 0) : 0)}
        inventoryMaxWeight={holsterData.maxweight}
        inventorySlots={holsterData.slots}
        inventoryItems={holsterData.items}
        isShopInventory={false}
        shouldCenterInventory={false}
        t={t}
        playerMoney={0}
        getItemInSlot={getItemInSlot}
        useItem={useItem}
        handleMouseDown={handleMouseDown}
        showItemInfo={showItemInfo}
        hideItemInfo={hideItemInfo}
        selectedItem={selectedItem}
        showContextMenu={showContextMenu}
        errorSlot={errorSlot}
        hasOtherInventory={!isOtherInventoryEmpty}
        hotbarOffset={5}
        hotbarMaxSlots={3}
      />
    {/if}

    <!-- Player Satchel (Esquerdo) -->
    <InventoryPanel
      inventoryType="player"
      inventoryLabel={t.pocket}
      inventoryWeight={playerWeight}
      inventoryMaxWeight={maxWeight}
      inventorySlots={totalSlots}
      inventoryItems={playerInventory}
      isShopInventory={false}
      shouldCenterInventory={shouldCenterInventory}
      t={t}
      playerName={playerName}
      playerId={playerId}
      playerMoney={playerMoney}
      getItemInSlot={getItemInSlot}
      useItem={useItem}
      handleMouseDown={handleMouseDown}
      showItemInfo={showItemInfo}
      hideItemInfo={hideItemInfo}
      selectedItem={selectedItem}
      showContextMenu={showContextMenu}
      errorSlot={errorSlot}
      backpack={backpack}
      unequipBackpack={unequipBackpack}
      equipmentSlots={equipmentSlots}
      handleEquipmentClick={handleEquipmentClick}
    />

    <!-- Close button left satchel -->
    <div 
      class="close-btn player-close-btn" 
      class:centered-close-btn={shouldCenterInventory}
      onclick={closeInventory}
    >
      {t.close}
    </div>

    <!-- Input quantity panel -->
    {#if (!isOtherInventoryEmpty || isSatchelOpen || isBackpackOpen || isWalletOpen || isHolsterOpen) && !isTradeActive}
      <div class="input-container" class:centered-input-container={shouldCenterInventory}>
        <div class="input-wrapper">
          <input type="number" bind:value={transferAmount} min="1" placeholder={transferAmount === null ? t.amount_placeholder : ''} />
          <button onclick={clearTransferAmount} class="clear-button">
            <i class="fas fa-times"></i>
          </button>
        </div>
      </div>
    {/if}

    <!-- Other Satchel (Direito) -->
    {#if !isOtherInventoryEmpty && !isTradeActive}
      <InventoryPanel
        inventoryType="other"
        inventoryLabel={otherInventoryLabel}
        inventoryWeight={otherInventoryWeight}
        inventoryMaxWeight={otherInventoryMaxWeight}
        inventorySlots={otherInventorySlots}
        inventoryItems={otherInventory}
        isShopInventory={isShopInventory}
        shouldCenterInventory={false}
        t={t}
        playerMoney={0}
        getItemInSlot={getItemInSlot}
        useItem={useItem}
        handleMouseDown={handleMouseDown}
        showItemInfo={showItemInfo}
        hideItemInfo={hideItemInfo}
        selectedItem={selectedItem}
        showContextMenu={showContextMenu}
        errorSlot={errorSlot}
        hotbarOffset={otherInventoryHotbarOffset}
        hotbarMaxSlots={otherInventoryHotbarMaxSlots}
      />
      <!-- Close button right satchel -->
      <div 
        class="close-btn other-close-btn" 
        onclick={closeInventory}
      >
        {t.close}
      </div>
    {/if}

    <!-- Trade Panel -->
    {#if isTradeActive}
      <TradePanel
        tradePartnerName={tradePartnerName}
        myTradeOffers={myTradeOffers}
        theirTradeOffers={theirTradeOffers}
        myTradeAccepted={myTradeAccepted}
        theirTradeAccepted={theirTradeAccepted}
        t={t}
        confirmTrade={confirmTrade}
        cancelTrade={cancelTrade}
        removeItemFromTrade={removeItemFromTrade}
      />
    {/if}

    <!-- Context Menu Options (Dar, Usar, Dividir) -->
    {#if showContextMenu && contextMenuItem}
      <ContextMenu
        contextMenuItem={contextMenuItem}
        contextMenuPosition={contextMenuPosition}
        isTradeActive={isTradeActive}
        t={t}
        useItem={useItem}
        unequipItem={unequipItem}
        dropEquipmentItem={dropEquipmentItem}
        addItemToTrade={addItemToTrade}
        addItemToTradeWithPrompt={addItemToTradeWithPrompt}
        giveItem={giveItem}
        dropItem={dropItem}
        splitAndPlaceItem={splitAndPlaceItem}
        copySerial={copySerial}
        searchBackpack={searchBackpack}
      />
    {/if}
  </div>
{/if}

<!-- Hotbar HUD -->
{#if showHotbar}
  <div class="hotbar-container">
    <div class="hotbar">
      {#each Array(8) as _, idx}
        {@const slot = idx + 1}
        {@const item = hotbarItems[idx] || null}
        {@const isLocked = !activeHotbarSlots[slot]}
        <div class="item-slot {isLocked ? 'locked-slot' : ''}">
          <div class="item-slot-key">
            <p>{slot}</p>
          </div>
          {#if isLocked}
            <div class="locked-icon">
              <i class="fas fa-lock"></i>
            </div>
          {/if}
          {#if item}
            <div class="item-slot-img">
              <img src="images/{item.image}" alt="" />
            </div>
            <div class="item-slot-amount">
              <p>x{item.amount}</p>
            </div>
            {#if item.info && typeof item.info === 'object' && 'quality' in item.info}
              <div class="item-slot-durability">
                <div 
                  class="item-slot-durability-fill"
                  style="width: {item.info.quality}%"
                  class:high={item.info.quality > 75}
                  class:medium={item.info.quality <= 75 && item.info.quality > 25}
                  class:low={item.info.quality <= 25}
                ></div>
              </div>
            {/if}
            <div class="item-slot-label">
              <p>{item.label}</p>
            </div>
          {/if}
        </div>
      {/each}
    </div>
  </div>
{/if}

<!-- Item Action Notification HUD -->
{#if showNotification}
  <div class="notification-container">
    <div class="item-box">
      <div class="item-box-icon">
        <img src={notificationImage} alt="" />
        {#if notificationAmount && notificationAmount > 1}
          <div class="item-box-amount">x{notificationAmount}</div>
        {/if}
      </div>
      <div class="item-box-content">
        <div class="item-box-type type-{(notificationClass || '').toLowerCase()}">{notificationType}</div>
        <div class="item-box-divider"></div>
        <div class="item-box-header">
          <h4>{notificationText}</h4>
        </div>
        {#if notificationDescription}
          <div class="item-box-description">
            <p>{@html notificationDescription}</p>
          </div>
        {/if}
      </div>
    </div>
  </div>
{/if}

<!-- Dragging ghost element -->
{#if isDragging && currentlyDraggingItem}
  <div 
    class="item-slot dragged-item" 
    style="position: absolute; pointer-events: none; opacity: 0.7; z-index: 1000; left: {dragX}px; top: {dragY}px; width: 4.5vw; height: 4.5vw; background: rgba(10, 10, 10, 0.9); border: 1px solid rgba(255,255,255,0.4);"
  >
    <div class="item-slot-img">
      <img src="images/{currentlyDraggingItem.image}" alt="" />
    </div>
    <div class="item-slot-amount">
      <p>x{transferAmount !== null ? transferAmount : currentlyDraggingItem.amount}</p>
    </div>
    <div class="item-slot-label">
      <p>{currentlyDraggingItem.label}</p>
    </div>
  </div>
{/if}
