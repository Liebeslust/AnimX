-----------------------------------
-- LABELS
-----------------------------------	
CustomLabels = {
    EnterFileName = LOC.labels.enterFileName,
    InvalidChar = LOC.labels.invalidChar,
    EnterValue = LOC.labels.enterValue,
    ValueMustBeNumber = LOC.labels.valueMustBeNumber,
    Search = LOC.labels.search
}

for key, text in pairs(CustomLabels) do CustomLabels[key] = util.register_label(text) end

