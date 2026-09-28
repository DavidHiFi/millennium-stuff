import { callable, ConfirmModal, pluginSelf, showModal } from '@steambrew/client';

type OriginalOpenFunction = (url?: string, target?: string, features?: string, replace?: boolean) => Window | null;
const originalOpen: OriginalOpenFunction = window.open;

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
}
