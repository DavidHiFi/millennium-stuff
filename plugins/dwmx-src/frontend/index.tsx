import { callable, ConfirmModal, pluginSelf, showModal } from '@steambrew/client';

type OriginalOpenFunction = (url?: string, target?: string, features?: string, replace?: boolean) => Window | null;
const originalOpen: OriginalOpenFunction = window.open;

// Native popup windows cannot use CSS backdrop-filter to sample another
// window. Apply the native material when Steam shows a pre-created popup.
const watchedWindows = new WeakSet<Window>();
let pendingPatch: ReturnType<typeof setTimeout> | undefined;
function patchAfterShow() {
	if (pendingPatch !== undefined) return;
	pendingPatch = setTimeout(() => {
		pendingPatch = undefined;
		callable<[]>('PatchAllWindows')();
		setTimeout(() => { callable<[]>('PatchAllWindows')(); }, 100);
	}, 0);
}
function watchWindow(popup: Window | null | undefined) {
	if (!popup || watchedWindows.has(popup)) return;
	watchedWindows.add(popup);
	const nativeWindow = (popup as any).SteamClient?.Window;
	for (const method of ['ShowWindow', 'BringToFront']) {
		const original = nativeWindow?.[method];
		if (typeof original !== 'function') continue;
		nativeWindow[method] = function (...args: unknown[]) {
			const result = original.apply(this, args);
			patchAfterShow();
			return result;
		};
	}
	popup.document.addEventListener('visibilitychange', () => {
		if (!popup.document.hidden) patchAfterShow();
	});
	popup.addEventListener('focus', patchAfterShow);
}

const Patches = {
	TARGET_WINDOW_FLAG: [4114, 2],
	// Resizable | Composited | TransparentParentWindow: keeps windows
	// transparency-capable so the theme's translucent surfaces show the blur.
	NEW_WINDOW_FLAG: 4194576,
};

window.open = function (url?: string, target?: string, features?: string, replace?: boolean): Window | null {
	if (!url) {
		return originalOpen(url, target, features, replace);
	}

	const parsedUrl = new URL(url);
	const queryParams = parsedUrl.searchParams;

	const windowFeature = 'createflags';

	if (queryParams.has(windowFeature) && Patches.TARGET_WINDOW_FLAG.includes(parseInt(queryParams.get(windowFeature) || ''))) {
		queryParams.set(windowFeature, Patches.NEW_WINDOW_FLAG.toString());
		parsedUrl.search = queryParams.toString();
		url = parsedUrl.toString();
	}

	callable<[]>('PatchAllWindows')();

	// Steam creates the new window's HWND asynchronously, so re-patch a few
	// times after opening: this is what gives context menus and popups the
	// window backdrop too, not just windows that already existed.
	const opened = originalOpen(url, target, features, replace);
	watchWindow(opened);
	for (const delay of [0, 100, 300, 800]) {
		setTimeout(() => { callable<[]>('PatchAllWindows')(); }, delay);
	}
	return opened;
};

const ShowAlertMessage = (strTitle: string, strMessage: string) => showModal(<ConfirmModal strTitle={strTitle} strDescription={strMessage} />);

export default async function PluginMain() {
	pluginSelf.ShowAlertMessage = ShowAlertMessage;

	// Steam creates/recreates its windows around the time plugins load, and an
	// accent set before a window's composition target exists is dropped. Re-apply
	// a few times shortly after load so the main window keeps its backdrop.
	for (const delay of [500, 1500, 3000, 6000, 10000]) {
		setTimeout(() => { callable<[]>('PatchAllWindows')(); }, delay);
	}

	const manager = (window as any).g_PopupManager;
	if (manager) {
		for (const popup of manager.GetPopups()) watchWindow(popup.m_popup);
		manager.AddPopupCreatedCallback((popup: any) => {
			watchWindow(popup.m_popup);
			patchAfterShow();
		});
	}
}
