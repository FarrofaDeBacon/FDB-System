const resource = GetParentResourceName();
let lang = {};
let defaults = {};
let locks = {};
let draft = null;
let confirmCb = null;
let categories = [];
let jobPresets = [];
let categoryFilter = "";

function post(name, data = {}) {
    return fetch(`https://${resource}/${name}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
    });
}

function t(key) {
    return lang[key] || key;
}

function escapeHtml(value) {
    return String(value == null ? "" : value)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

function showNotification(message, type = "info") {
    const el = document.getElementById("notification");
    const msg = document.getElementById("notification-message");
    el.className = `notification ${type}`;
    msg.textContent = message;
    el.classList.remove("hidden");
    setTimeout(() => el.classList.add("hidden"), 3200);
}

function confirmDialog(title, message, onConfirm) {
    document.getElementById("confirmation-title").textContent = title;
    document.getElementById("confirmation-message").textContent = message;
    document.getElementById("confirmation-dialog").classList.remove("hidden");
    confirmCb = onConfirm;
}

function closeConfirm() {
    document.getElementById("confirmation-dialog").classList.add("hidden");
    confirmCb = null;
}

function switchTab(tab) {
    document.querySelectorAll(".admin-tab").forEach((btn) => {
        btn.classList.toggle("active", btn.dataset.tab === tab);
    });
    document.querySelectorAll(".admin-tab-content").forEach((panel) => {
        panel.classList.toggle("active", panel.id === `tab-${tab}`);
    });
    const title = document.getElementById("menu-title");
    if (title) {
        title.textContent = tab === "editor" ? t("tabEditor") : t("menuTitle");
    }
}

function jobEntries(jobAccess) {
    return Object.keys(jobAccess || {}).map((name) => ({
        name,
        grade: Number(jobAccess[name]) || 0,
    }));
}

function normalizeJobAccessClient(raw) {
    const out = {};
    if (!raw) return out;

    const setJob = (name, grade) => {
        const n = String(name || "").trim().toLowerCase();
        if (!n) return;
        const g = Number(grade);
        out[n] = Number.isFinite(g) ? g : 0;
    };

    if (Array.isArray(raw)) {
        raw.forEach((entry) => {
            if (typeof entry === "string") setJob(entry, 0);
            else if (entry && typeof entry === "object") {
                setJob(entry.name || entry.job || entry[0], entry.grade ?? entry.minGrade ?? entry.rank ?? entry[1] ?? 0);
            }
        });
        return out;
    }

    if (typeof raw === "object") {
        Object.keys(raw).forEach((key) => {
            const v = raw[key];
            if (v && typeof v === "object" && !Array.isArray(v)) {
                setJob(v.name || v.job || key, v.grade ?? v.minGrade ?? v.rank ?? v.level ?? 0);
            } else {
                setJob(key, v);
            }
        });
    }
    return out;
}

function jobAccessPayload(jobAccess) {
    return jobEntries(jobAccess).map((j) => ({
        name: j.name,
        grade: Number(j.grade) || 0,
    }));
}

function normalizeCategoryValue(value) {
    const s = String(value == null ? "" : value).trim();
    return s;
}

function collectKnownCategories() {
    const set = new Set();
    (categories || []).forEach((c) => {
        const n = normalizeCategoryValue(c);
        if (n) set.add(n);
    });
    Object.values(locks || {}).forEach((lock) => {
        const n = normalizeCategoryValue(lock && lock.category);
        if (n) set.add(n);
    });
    if (draft && draft.category) {
        const n = normalizeCategoryValue(draft.category);
        if (n) set.add(n);
    }
    return Array.from(set).sort((a, b) => a.localeCompare(b));
}

function normalizeJobPresets(raw) {
    const out = [];
    (raw || []).forEach((entry, idx) => {
        if (typeof entry === "string") {
            const name = entry.trim().toLowerCase();
            if (!name) return;
            out.push({ id: `p${idx}`, label: name, jobs: [{ name, grade: 0 }] });
            return;
        }
        if (!entry || typeof entry !== "object") return;
        if (Array.isArray(entry.jobs)) {
            const jobs = entry.jobs.map((j) => {
                if (typeof j === "string") return { name: j.trim().toLowerCase(), grade: 0 };
                const name = String(j.name || j.job || "").trim().toLowerCase();
                return { name, grade: Number(j.grade ?? j.minGrade ?? 0) || 0 };
            }).filter((j) => j.name);
            if (!jobs.length) return;
            out.push({
                id: `p${idx}`,
                label: String(entry.label || jobs.map((j) => j.name).join(", ")),
                jobs,
            });
            return;
        }
        const name = String(entry.name || entry.job || "").trim().toLowerCase();
        if (!name) return;
        out.push({
            id: `p${idx}`,
            label: String(entry.label || name),
            jobs: [{ name, grade: Number(entry.grade ?? entry.minGrade ?? 0) || 0 }],
        });
    });
    return out;
}

function syncJobsFromDom() {
    if (!draft) return;
    const out = {};
    document.querySelectorAll(".job-lock-row").forEach((row) => {
        const name = (row.querySelector(".job-name-input")?.value || "").trim().toLowerCase();
        const grade = parseInt(row.querySelector(".job-grade-input")?.value, 10);
        if (name) out[name] = Number.isNaN(grade) ? 0 : grade;
    });
    draft.jobAccess = out;
}

function syncDraftFromFields() {
    if (!draft) return false;
    const nameEl = document.getElementById("field-name");
    if (!nameEl) return false;

    draft.name = nameEl.value;
    const catEl = document.getElementById("field-category");
    if (catEl) draft.category = normalizeCategoryValue(catEl.value);

    const radiusEl = document.getElementById("field-radius");
    if (radiusEl) draft.promptRadius = parseFloat(radiusEl.value) || 2;

    const searchRadiusEl = document.getElementById("field-door-search-radius");
    if (searchRadiusEl) {
        draft.doorSearchRadius = parseFloat(searchRadiusEl.value) || defaults.doorSearchRadius || 3;
    }

    const px = parseFloat(document.getElementById("prompt-x")?.value);
    const py = parseFloat(document.getElementById("prompt-y")?.value);
    const pz = parseFloat(document.getElementById("prompt-z")?.value);
    if (!Number.isNaN(px) && !Number.isNaN(py) && !Number.isNaN(pz)) {
        draft.prompt = { x: px, y: py, z: pz };
    }

    const lockpickEl = document.getElementById("field-lockpick-item");
    if (lockpickEl) draft.lockpickItem = lockpickEl.value.trim();
    const accessEl = document.getElementById("field-access-item");
    if (accessEl) draft.accessItem = accessEl.value.trim();

    syncJobsFromDom();

    const charsEl = document.getElementById("field-chars");
    if (charsEl) draft.charAccess = parseChars(charsEl.value);

    const closedEl = document.getElementById("field-closed-ratio");
    if (closedEl) draft.closedRatio = parseFloat(closedEl.value) || 0;

    return true;
}

function rerenderEditor() {
    syncDraftFromFields();
    renderEditor();
}

function panelDisplayName(panel, idx) {
    const label = panel.modelName || panel.model || panel.hash;
    return t("panelInfo")
        .replace("{n}", String(idx + 1))
        .replace("{hash}", String(label));
}

function renderJobRows() {
    const entries = jobEntries(draft.jobAccess);
    if (!entries.length) {
        return `<div class="job-lock-empty">${escapeHtml(t("noJobs"))}</div>`;
    }
    return entries.map((job, idx) => `
        <div class="job-lock-row" data-job-idx="${idx}">
            <input class="admin-input job-name-input" list="job-preset-datalist" value="${escapeHtml(job.name)}" placeholder="${escapeHtml(t("jobsPh"))}">
            <input class="admin-input job-grade-input" type="number" min="0" step="1" value="${escapeHtml(job.grade)}" placeholder="${escapeHtml(t("jobGrade"))}" title="${escapeHtml(t("jobGradeHint"))}">
            <button type="button" class="admin-button-small" data-remove-job="${idx}">${escapeHtml(t("removeJob"))}</button>
        </div>
    `).join("");
}

function renderJobPresetChips() {
    if (!jobPresets.length) return "";
    const chips = jobPresets.map((preset) => `
        <button type="button" class="preset-chip" data-job-preset="${escapeHtml(preset.id)}" title="${escapeHtml(preset.jobs.map((j) => `${j.name}:${j.grade}`).join(", "))}">
            ${escapeHtml(preset.label)}
        </button>
    `).join("");
    return `
        <div class="preset-row">
            <div class="preset-label">${escapeHtml(t("jobPresets"))}</div>
            <div class="preset-chips">${chips}</div>
        </div>
    `;
}

function jobPresetDatalistHtml() {
    const names = new Set();
    jobPresets.forEach((p) => p.jobs.forEach((j) => names.add(j.name)));
    if (!names.size) return "";
    return `<datalist id="job-preset-datalist">${Array.from(names).map((n) => `<option value="${escapeHtml(n)}"></option>`).join("")}</datalist>`;
}

function emptyDraft() {
    return {
        id: null,
        name: "",
        category: defaults.category || "",
        double: false,
        panels: [],
        prompt: null,
        promptRadius: defaults.promptRadius || 2,
        doorSearchRadius: defaults.doorSearchRadius || 3,
        lockedOnStart: defaults.lockedOnStart !== false,
        showPrompt: defaults.showPrompt !== false,
        show3d: defaults.show3d === true,
        canLockpick: defaults.canLockpick === true,
        lockpickItem: "",
        accessItem: "",
        jobAccess: {},
        charAccess: [],
        closedRatio: defaults.closedRatio || 0,
    };
}

function parseChars(text) {
    const out = [];
    const seen = {};
    if (!text) return out;
    text.split(",").forEach((part) => {
        const s = String(part || "").trim();
        if (!s || seen[s]) return;
        seen[s] = true;
        const n = Number(s);
        out.push(Number.isInteger(n) && String(n) === s ? n : s);
    });
    return out;
}

function charsToText(chars) {
    return (chars || []).join(", ");
}

function badgeHtml(value, onLabel, offLabel) {
    const on = value === true;
    return `<span class="admin-status-badge ${on ? "status-on" : "status-off"}" data-toggle="${on ? "1" : "0"}">${on ? escapeHtml(onLabel) : escapeHtml(offLabel)}</span>`;
}

function categoryOptionsHtml(selected) {
    const known = collectKnownCategories();
    const sel = normalizeCategoryValue(selected);
    const opts = [`<option value="">${escapeHtml(t("categoryNone"))}</option>`];
    known.forEach((c) => {
        opts.push(`<option value="${escapeHtml(c)}" ${c === sel ? "selected" : ""}>${escapeHtml(c)}</option>`);
    });
    if (sel && !known.includes(sel)) {
        opts.push(`<option value="${escapeHtml(sel)}" selected>${escapeHtml(sel)}</option>`);
    }
    return opts.join("");
}

function applyJobPreset(presetId) {
    syncJobsFromDom();
    const preset = jobPresets.find((p) => p.id === presetId);
    if (!preset) return;
    draft.jobAccess = draft.jobAccess || {};
    let added = 0;
    preset.jobs.forEach((job) => {
        if (draft.jobAccess[job.name] == null) {
            draft.jobAccess[job.name] = job.grade;
            added += 1;
        }
    });
    if (!added) showNotification(t("jobAlreadyAdded"), "info");
    renderEditor();
}

function addJobsFromBulkText(text) {
    syncJobsFromDom();
    draft.jobAccess = draft.jobAccess || {};
    let added = 0;
    String(text || "").split(/[,;\n]+/).forEach((part) => {
        const raw = String(part || "").trim();
        if (!raw) return;
        const m = raw.match(/^([a-zA-Z0-9_\-]+)\s*[:=]?\s*(\d+)?$/);
        if (!m) return;
        const name = m[1].toLowerCase();
        const grade = m[2] != null ? parseInt(m[2], 10) : 0;
        if (!name) return;
        if (draft.jobAccess[name] == null) added += 1;
        draft.jobAccess[name] = Number.isNaN(grade) ? 0 : grade;
    });
    return added;
}

function renderEditor() {
    const root = document.getElementById("editor-fields");
    if (!draft) draft = emptyDraft();
    const p = draft.prompt || {};
    const px = p.x != null ? Number(p.x).toFixed(2) : "";
    const py = p.y != null ? Number(p.y).toFixed(2) : "";
    const pz = p.z != null ? Number(p.z).toFixed(2) : "";
    const knownCats = collectKnownCategories();

    const panelRows = (draft.panels || []).map((panel, idx) => `
        <div class="panel-row">
            <div class="panel-row-info">
                <span class="panel-row-title">${escapeHtml(panelDisplayName(panel, idx))}</span>
            </div>
            <button type="button" class="admin-button-small panel-row-remove" data-remove-panel="${idx}">${escapeHtml(t("removePanel"))}</button>
        </div>
    `).join("");

    root.innerHTML = `
        <div class="editor-group">
            <div class="editor-group-title">${escapeHtml(t("sectionIdentity"))}</div>
            <div class="admin-section admin-section--compact">
                <div class="admin-label">${escapeHtml(t("name"))}</div>
                <input class="admin-input" id="field-name" value="${escapeHtml(draft.name || "")}" placeholder="${escapeHtml(t("namePh"))}">
            </div>
            <div class="admin-section admin-section--compact admin-section--last">
                <div class="admin-label">${escapeHtml(t("category"))}</div>
                <div class="admin-hint">${escapeHtml(t("categoryHint"))}</div>
                <div class="category-edit">
                    <div class="category-field">
                        <div class="field-micro-label">${escapeHtml(t("categoryPreset"))}</div>
                        <select class="admin-input" id="field-category-select">
                            ${categoryOptionsHtml(draft.category)}
                        </select>
                    </div>
                    <div class="category-field">
                        <div class="field-micro-label">${escapeHtml(t("categoryCustom"))}</div>
                        <input class="admin-input" id="field-category" list="category-datalist" value="${escapeHtml(draft.category || "")}" placeholder="${escapeHtml(t("categoryPh"))}">
                    </div>
                </div>
                <datalist id="category-datalist">${knownCats.map((c) => `<option value="${escapeHtml(c)}"></option>`).join("")}</datalist>
            </div>
        </div>

        <div class="editor-group">
            <div class="editor-group-title">${escapeHtml(t("sectionDoor"))}</div>
            <div class="admin-section admin-section--compact">
                <div class="admin-label">${escapeHtml(t("doorType"))}</div>
                <div class="toggle-button-group">
                    <button type="button" class="toggle-button ${!draft.double ? "active" : ""}" data-door-type="single">${escapeHtml(t("single"))}</button>
                    <button type="button" class="toggle-button ${draft.double ? "active" : ""}" data-door-type="double">${escapeHtml(t("double"))}</button>
                </div>
            </div>
            <div class="admin-section admin-section--compact">
                <div class="admin-label">${escapeHtml(t("panels"))}</div>
                <div class="positions-list" id="panel-list">${panelRows || `<div class="zone-detail-value">${escapeHtml(t("noPanels"))}</div>`}</div>
                <div class="coord-inputs panel-actions">
                    <input class="admin-input" id="field-door-search-radius" type="number" step="0.1" min="0.5" max="25" value="${draft.doorSearchRadius != null ? draft.doorSearchRadius : (defaults.doorSearchRadius || 3)}" title="${escapeHtml(t("doorSearchRadius"))}">
                    <button type="button" class="admin-button-small" id="search-door-btn">${escapeHtml(t("searchDoorAtPrompt"))}</button>
                </div>
            </div>
            <div class="admin-section admin-section--compact">
                <div class="admin-label">${escapeHtml(t("promptPos"))}</div>
                <div class="coord-inputs">
                    <input class="admin-input coord-input" id="prompt-x" placeholder="X" value="${escapeHtml(px)}">
                    <input class="admin-input coord-input" id="prompt-y" placeholder="Y" value="${escapeHtml(py)}">
                    <input class="admin-input coord-input" id="prompt-z" placeholder="Z" value="${escapeHtml(pz)}">
                    <button type="button" class="admin-button-small" id="prompt-pos-btn">${escapeHtml(t("useMyPos"))}</button>
                </div>
            </div>
            <div class="admin-section admin-section--compact admin-section--last">
                <div class="admin-label">${escapeHtml(t("promptRadius"))}</div>
                <input class="admin-input" id="field-radius" type="number" step="0.1" min="0.5" max="10" value="${draft.promptRadius || 2}">
            </div>
        </div>

        <div class="editor-group">
            <div class="editor-group-title">${escapeHtml(t("sectionOptions"))}</div>
            <div class="options-grid">
                <div class="admin-section admin-status-container admin-section--compact">
                    <div class="admin-label">${escapeHtml(t("lockedOnStart"))}</div>
                    ${badgeHtml(draft.lockedOnStart, t("on"), t("off"))}
                </div>
                <div class="admin-section admin-status-container admin-section--compact">
                    <div class="admin-label">${escapeHtml(t("showPrompt"))}</div>
                    ${badgeHtml(draft.showPrompt, t("on"), t("off"))}
                </div>
                <div class="admin-section admin-status-container admin-section--compact">
                    <div class="admin-label">${escapeHtml(t("show3d"))}</div>
                    ${badgeHtml(draft.show3d, t("on"), t("off"))}
                </div>
                <div class="admin-section admin-status-container admin-section--compact">
                    <div class="admin-label">${escapeHtml(t("canLockpick"))}</div>
                    ${badgeHtml(draft.canLockpick, t("on"), t("off"))}
                </div>
            </div>
            <div class="admin-section admin-section--compact">
                <div class="admin-label">${escapeHtml(t("lockpickItem"))}</div>
                <input class="admin-input" id="field-lockpick-item" value="${escapeHtml(draft.lockpickItem || "")}" placeholder="${escapeHtml(t("accessItemPh"))}">
            </div>
            <div class="admin-section admin-section--compact admin-section--last">
                <div class="admin-label">${escapeHtml(t("accessItem"))}</div>
                <input class="admin-input" id="field-access-item" value="${escapeHtml(draft.accessItem || "")}" placeholder="${escapeHtml(t("accessItemPh"))}">
            </div>
        </div>

        <div class="editor-group">
            <div class="editor-group-title">${escapeHtml(t("sectionAccess"))}</div>
            <div class="admin-section admin-section--compact">
                <div class="admin-label">${escapeHtml(t("jobs"))}</div>
                <div class="admin-hint">${escapeHtml(t("jobsHint"))}</div>
                ${renderJobPresetChips()}
                <div class="job-lock-list" id="job-lock-list">${renderJobRows()}</div>
                ${jobPresetDatalistHtml()}
                <div class="job-actions-row">
                    <button type="button" class="admin-button-small" id="add-job-btn">${escapeHtml(t("addJob"))}</button>
                </div>
                <div class="job-bulk-row">
                    <input class="admin-input" id="field-job-bulk" placeholder="${escapeHtml(t("jobBulkPh"))}">
                    <button type="button" class="admin-button-small" id="add-job-bulk-btn">${escapeHtml(t("jobBulkAdd"))}</button>
                </div>
            </div>
            <div class="admin-section admin-section--compact admin-section--last">
                <div class="admin-label">${escapeHtml(t("chars"))}</div>
                <input class="admin-input" id="field-chars" value="${escapeHtml(charsToText(draft.charAccess))}" placeholder="${escapeHtml(t("charsPh"))}">
            </div>
        </div>

        <div class="editor-group editor-group--last">
            <div class="editor-group-title">${escapeHtml(t("sectionAdvanced"))}</div>
            <div class="admin-section admin-section--compact admin-section--last">
                <div class="admin-label">${escapeHtml(t("closedRatio"))}</div>
                <div class="coord-inputs closed-ratio-row">
                    <input class="admin-input" id="field-closed-ratio" type="number" step="0.01" min="0" max="1" value="${draft.closedRatio || 0}">
                    <button type="button" class="admin-button-small" id="capture-closed-btn">${escapeHtml(t("captureClosed"))}</button>
                </div>
            </div>
        </div>
    `;

    root.querySelectorAll("[data-door-type]").forEach((btn) => {
        btn.addEventListener("click", () => {
            syncDraftFromFields();
            draft.double = btn.dataset.doorType === "double";
            renderEditor();
        });
    });

    root.querySelectorAll(".admin-status-badge").forEach((badge, idx) => {
        const keys = ["lockedOnStart", "showPrompt", "show3d", "canLockpick"];
        const key = keys[idx];
        badge.addEventListener("click", () => {
            syncDraftFromFields();
            draft[key] = !draft[key];
            renderEditor();
        });
    });

    root.querySelectorAll("[data-remove-panel]").forEach((btn) => {
        btn.addEventListener("click", () => {
            syncDraftFromFields();
            const i = parseInt(btn.dataset.removePanel, 10);
            draft.panels.splice(i, 1);
            renderEditor();
        });
    });

    const catSelect = document.getElementById("field-category-select");
    const catInput = document.getElementById("field-category");
    if (catSelect && catInput) {
        catSelect.addEventListener("change", () => {
            catInput.value = catSelect.value;
            draft.category = normalizeCategoryValue(catInput.value);
        });
        catInput.addEventListener("input", () => {
            draft.category = normalizeCategoryValue(catInput.value);
            if (Array.from(catSelect.options).some((o) => o.value === draft.category)) {
                catSelect.value = draft.category;
            } else {
                catSelect.value = "";
            }
        });
    }

    document.getElementById("search-door-btn").addEventListener("click", () => {
        syncDraftFromFields();
        const need = draft.double ? Math.max(0, 2 - (draft.panels || []).length) : 1;
        if (draft.double && (draft.panels || []).length >= 2) return;
        const prompt = draft.prompt || {};
        if (prompt.x == null || prompt.y == null || prompt.z == null) {
            showNotification(t("doorSearchNeedPrompt"), "error");
            return;
        }
        const radius = parseFloat(document.getElementById("field-door-search-radius").value)
            || defaults.doorSearchRadius
            || 3;
        draft.doorSearchRadius = radius;
        post("searchDoorAtPrompt", { x: prompt.x, y: prompt.y, z: prompt.z, radius, need, double: draft.double });
    });

    document.getElementById("add-job-btn").addEventListener("click", () => {
        syncJobsFromDom();
        let n = 1;
        while (draft.jobAccess[`job${n}`] != null) n += 1;
        draft.jobAccess[`job${n}`] = 0;
        renderEditor();
    });

    document.getElementById("add-job-bulk-btn").addEventListener("click", () => {
        const input = document.getElementById("field-job-bulk");
        const added = addJobsFromBulkText(input ? input.value : "");
        if (input) input.value = "";
        if (!added) return;
        renderEditor();
    });

    root.querySelectorAll("[data-job-preset]").forEach((btn) => {
        btn.addEventListener("click", () => applyJobPreset(btn.dataset.jobPreset));
    });

    root.querySelectorAll("[data-remove-job]").forEach((btn) => {
        btn.addEventListener("click", () => {
            syncJobsFromDom();
            const entries = jobEntries(draft.jobAccess);
            const i = parseInt(btn.dataset.removeJob, 10);
            entries.splice(i, 1);
            const next = {};
            entries.forEach((e) => { next[e.name] = e.grade; });
            draft.jobAccess = next;
            renderEditor();
        });
    });

    root.querySelectorAll(".job-name-input, .job-grade-input").forEach((input) => {
        input.addEventListener("change", syncJobsFromDom);
        input.addEventListener("blur", syncJobsFromDom);
    });

    document.getElementById("prompt-pos-btn").addEventListener("click", () => {
        syncDraftFromFields();
        const payload = {};
        const prompt = draft.prompt || {};
        if (prompt.x != null && prompt.y != null && prompt.z != null) {
            payload.x = prompt.x;
            payload.y = prompt.y;
            payload.z = prompt.z;
        }
        post("getPosition", payload);
    });
    document.getElementById("capture-closed-btn").addEventListener("click", () => {
        syncDraftFromFields();
        const hash = draft.panels && draft.panels[0] ? draft.panels[0].hash : null;
        post("captureClosed", { hash });
    });
}

function readDraftFromFields() {
    if (!draft) draft = emptyDraft();
    syncDraftFromFields();
    draft.name = (document.getElementById("field-name")?.value || "").trim() || "Door";
    draft.category = normalizeCategoryValue(document.getElementById("field-category")?.value || draft.category || "");
    if (draft.accessItem === "false" || draft.accessItem === "") draft.accessItem = false;
    if (draft.lockpickItem === "false" || draft.lockpickItem === "") draft.lockpickItem = false;
    return draft;
}

function buildSavePayload() {
    const data = readDraftFromFields();
    return {
        ...data,
        jobAccess: jobAccessPayload(data.jobAccess || {}),
    };
}

function normalizeLocksMap(raw) {
    const out = {};
    Object.values(raw || {}).forEach((lock) => {
        if (!lock || lock.id == null) return;
        out[Number(lock.id)] = lock;
    });
    return out;
}

function findLock(id) {
    id = Number(id);
    if (Number.isNaN(id)) return null;
    if (locks && locks[id]) return locks[id];
    if (locks && locks[String(id)]) return locks[String(id)];
    return Object.values(locks || {}).find((l) => Number(l.id) === id) || null;
}

function openEditorForLock(id) {
    const lock = findLock(id);
    if (!lock) {
        showNotification(t("noPanels"), "error");
        return;
    }
    draft = JSON.parse(JSON.stringify(lock));
    draft.jobAccess = normalizeJobAccessClient(draft.jobAccess);
    draft.category = normalizeCategoryValue(draft.category);
    renderEditor();
    switchTab("editor");
}

function renderLocksList() {
    const container = document.getElementById("locks-list");
    const knownCats = collectKnownCategories();
    let entries = Object.values(locks || {}).sort((a, b) => (a.id || 0) - (b.id || 0));
    if (categoryFilter) {
        entries = entries.filter((lock) => normalizeCategoryValue(lock.category) === categoryFilter);
    }

    const filterHtml = `
        <div class="locks-toolbar">
            <select class="admin-input locks-category-filter" id="locks-category-filter">
                <option value="">${escapeHtml(t("categoryFilter"))}</option>
                ${knownCats.map((c) => `<option value="${escapeHtml(c)}" ${c === categoryFilter ? "selected" : ""}>${escapeHtml(c)}</option>`).join("")}
            </select>
        </div>
    `;

    if (!entries.length) {
        container.innerHTML = `${filterHtml}<div class="locks-empty">${escapeHtml(t("noLocks"))}</div>`;
    } else {
        container.innerHTML = `${filterHtml}<div class="zones-list">${entries.map((lock) => {
            const cat = normalizeCategoryValue(lock.category);
            return `
            <div class="zone-list-item">
                <div class="zone-list-header">
                    <div class="zone-list-meta">
                        <div class="zone-list-name">${escapeHtml(lock.name || ("#" + lock.id))}</div>
                        ${cat ? `<div class="zone-list-category">${escapeHtml(cat)}</div>` : ""}
                    </div>
                    <div class="zone-list-actions">
                        <span class="zone-status-badge ${lock.locked ? "disabled" : "enabled"}">${escapeHtml(lock.locked ? t("locked") : t("unlocked"))}</span>
                        <button type="button" class="zone-expand-btn" data-edit="${lock.id}">${escapeHtml(t("edit"))}</button>
                        <button type="button" class="zone-expand-btn zone-expand-btn--danger" data-delete="${lock.id}">${escapeHtml(t("delete"))}</button>
                    </div>
                </div>
            </div>`;
        }).join("")}</div>`;
    }

    const filterEl = document.getElementById("locks-category-filter");
    if (filterEl) {
        filterEl.addEventListener("change", () => {
            categoryFilter = filterEl.value || "";
            renderLocksList();
        });
    }

    container.querySelectorAll("[data-edit]").forEach((btn) => {
        btn.addEventListener("click", (e) => {
            e.preventDefault();
            e.stopPropagation();
            openEditorForLock(btn.dataset.edit);
        });
    });

    container.querySelectorAll("[data-delete]").forEach((btn) => {
        btn.addEventListener("click", (e) => {
            e.preventDefault();
            e.stopPropagation();
            const id = parseInt(btn.dataset.delete, 10);
            confirmDialog(t("confirmDeleteTitle"), t("confirmDelete"), () => post("deleteLock", { id }));
        });
    });
}

function openMenu(payload) {
    lang = payload.lang || {};
    defaults = payload.defaults || {};
    locks = normalizeLocksMap(payload.locks || {});
    categories = Array.isArray(payload.categories) ? payload.categories : [];
    jobPresets = normalizeJobPresets(payload.jobPresets || []);
    categoryFilter = "";
    document.getElementById("menu-title").textContent = t("menuTitle");
    document.getElementById("tab-locks-label").textContent = t("tabLocks");
    document.getElementById("tab-editor-label").textContent = t("tabEditor");
    document.getElementById("create-lock-btn").textContent = t("newLock");
    document.getElementById("save-lock-btn").textContent = t("save");
    document.getElementById("cancel-edit-btn").textContent = t("cancel");
    document.getElementById("confirmation-cancel").textContent = t("confirmNo");
    document.getElementById("confirmation-confirm").textContent = t("confirmYes");
    document.getElementById("admin-menu").classList.remove("hidden");
    renderLocksList();
    switchTab("locks");
}

document.getElementById("admin-close").addEventListener("click", () => {
    document.getElementById("admin-menu").classList.add("hidden");
    post("close");
});

document.getElementById("admin-lock-toggle").addEventListener("click", () => {
    const btn = document.getElementById("admin-lock-toggle");
    const locked = !btn.classList.contains("locked");
    btn.classList.toggle("locked", locked);
    btn.classList.toggle("unlocked", !locked);
    post("toggleLock", { locked });
});

document.querySelectorAll(".admin-tab").forEach((tab) => {
    tab.addEventListener("click", () => switchTab(tab.dataset.tab));
});

document.getElementById("create-lock-btn").addEventListener("click", () => {
    draft = emptyDraft();
    renderEditor();
    switchTab("editor");
});

document.getElementById("cancel-edit-btn").addEventListener("click", () => {
    draft = null;
    switchTab("locks");
});

document.getElementById("save-lock-btn").addEventListener("click", () => {
    const data = buildSavePayload();
    if (!data.panels || data.panels.length < 1) {
        showNotification(t("noPanels"), "error");
        return;
    }
    if (data.double && data.panels.length < 2) {
        showNotification(t("pickNeedTwo"), "error");
        return;
    }
    post("saveLock", data);
});

document.getElementById("confirmation-cancel").addEventListener("click", closeConfirm);
document.getElementById("confirmation-confirm").addEventListener("click", () => {
    if (confirmCb) confirmCb();
    closeConfirm();
});

function renderPlacementHud(data) {
    const hud = document.getElementById("placement-hud");
    if (!hud) return;
    if (!data || !data.show) {
        hud.classList.remove("noclip-hud--visible");
        hud.setAttribute("aria-hidden", "true");
        return;
    }
    hud.classList.add("noclip-hud--visible");
    hud.setAttribute("aria-hidden", "false");
    if (data.title) {
        document.getElementById("ph-title").textContent = data.title;
    }
    const speed = document.getElementById("ph-speed");
    speed.textContent = data.fast ? (data.speedFast || "Fast") : (data.speedNormal || "Normal");
    speed.classList.toggle("noclip-hud__speed--fast", !!data.fast);
    if (Array.isArray(data.rows)) {
        const lines = document.getElementById("ph-lines");
        lines.innerHTML = data.rows.map((row) => {
            const keys = (row.keys || []).map((k, i) => {
                const sep = i > 0 ? `<span class="noclip-hud__keysep"></span>` : "";
                return `${sep}<span class="noclip-hud__kbd">${escapeHtml(k)}</span>`;
            }).join("");
            return `<li class="noclip-hud__row"><div class="noclip-hud__keys">${keys}</div><div class="noclip-hud__desc">${escapeHtml(row.label || "")}</div></li>`;
        }).join("");
    }
}

function setPreviewMode(on) {
    const menu = document.getElementById("admin-menu");
    if (!menu) return;
    menu.classList.toggle("preview-hidden", !!on);
}

function closeDoorPick() {
    document.getElementById("door-pick-modal").classList.add("hidden");
}

function addDoorFromSearch(hit) {
    syncDraftFromFields();
    if (!draft) draft = emptyDraft();
    if (!draft.panels) draft.panels = [];
    const hash = hit.hash;
    if (draft.panels.some((p) => String(p.hash) === String(hash))) return;
    const panel = {
        hash: hit.hash,
        model: hit.model,
        modelName: hit.modelName || (typeof hit.model === "string" ? hit.model : null),
        x: hit.x,
        y: hit.y,
        z: hit.z,
        heading: 0,
    };
    if (!draft.double && draft.panels.length >= 1) {
        draft.panels = [panel];
    } else {
        if (draft.double && draft.panels.length >= 2) return;
        draft.panels.push(panel);
    }
    closeDoorPick();
    renderEditor();
}

function openDoorSearch(doors) {
    syncDraftFromFields();
    const modal = document.getElementById("door-pick-modal");
    const list = document.getElementById("door-pick-list");
    document.getElementById("door-pick-title").textContent = t("doorSearchTitle");
    const existing = new Set((draft && draft.panels ? draft.panels : []).map((p) => String(p.hash)));
    const filtered = (doors || []).filter((d) => !existing.has(String(d.hash)));
    if (!filtered.length) {
        list.innerHTML = `<div class="zone-detail-value">${escapeHtml(t("doorSearchEmpty"))}</div>`;
    } else {
        list.innerHTML = filtered.map((d, idx) => {
            const name = d.modelName || (typeof d.model === "string" ? d.model : null) || `#${d.hash}`;
            const dist = (Number(d.dist) || 0).toFixed(2);
            return `<button type="button" class="door-pick-item" data-door-idx="${idx}">
                <div class="door-pick-main">
                    <div class="door-pick-name">${escapeHtml(name)}</div>
                    <div class="door-pick-meta">#${escapeHtml(d.hash)}</div>
                </div>
                <div class="door-pick-dist"><span class="door-pick-dist-value">${escapeHtml(dist)}</span><span class="door-pick-dist-unit">m</span></div>
            </button>`;
        }).join("");
        list.querySelectorAll("[data-door-idx]").forEach((btn) => {
            btn.addEventListener("click", () => {
                const i = parseInt(btn.dataset.doorIdx, 10);
                addDoorFromSearch(filtered[i]);
            });
        });
    }
    modal.classList.remove("hidden");
}

document.getElementById("door-pick-cancel").addEventListener("click", closeDoorPick);
document.getElementById("door-pick-overlay").addEventListener("click", closeDoorPick);

window.addEventListener("message", (event) => {
    const data = event.data || {};
    if (data.action === "open") openMenu(data);
    if (data.action === "refresh") {
        locks = normalizeLocksMap(data.locks || locks);
        renderLocksList();
        switchTab("locks");
    }
    if (data.action === "position") {
        syncDraftFromFields();
        if (!draft) draft = emptyDraft();
        draft.prompt = { x: data.x, y: data.y, z: data.z };
        renderEditor();
    }
    if (data.action === "closedCaptured") {
        syncDraftFromFields();
        if (!draft) draft = emptyDraft();
        draft.closedRatio = data.ratio || 0;
        renderEditor();
    }
    if (data.action === "doorSearch") openDoorSearch(data.doors || []);
    if (data.action === "placementHud") renderPlacementHud(data);
    if (data.action === "previewMode") setPreviewMode(data.on === true);
});

document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
        const pick = document.getElementById("door-pick-modal");
        if (pick && !pick.classList.contains("hidden")) {
            closeDoorPick();
            return;
        }
        const menu = document.getElementById("admin-menu");
        if (menu.classList.contains("preview-hidden")) return;
        menu.classList.add("hidden");
        post("close");
    }
});
