function jo.framework:getInventoryItems()
  local itemsFDB = self.core.Shared.Items
  local items = {}
  for id, item in pairs(itemsFDB) do
    local image = item.image or id
    if not image:match("%.%w+$") then
      image = image .. ".png"
    end
    items[id] = {
      item = id,
      label = item.label,
      type = item.type,
      description = item.description,
      image = "nui://fdb-inventory/html/images/" .. image
    }
  end
  return items
end
