import { writable, derived } from 'svelte/store';

export const isOpen = writable(false);
export const isLoading = writable(true);
export const maxCharacters = writable(5);
export const characters = writable([]);
export const selectedSlot = writable(null);
export const selectedCharData = writable(null);
export const showCreateForm = writable(false);
export const showDeleteConfirm = writable(false);

export const hasCharacters = derived(characters, ($c) => $c.length > 0);

export const isSlotOccupied = derived(
  [selectedSlot, characters],
  ([$slot, $chars]) => $slot !== null && $chars.some(c => c.cid === $slot)
);

export function resetAll() {
  isOpen.set(false);
  isLoading.set(true);
  characters.set([]);
  selectedSlot.set(null);
  selectedCharData.set(null);
  showCreateForm.set(false);
  showDeleteConfirm.set(false);
}
