const MILLENNIUM_IS_CLIENT_MODULE=!0,pluginName="dwmx";function InitializePlugins(){var e,n;let t;(e=window.PLUGIN_LIST||(window.PLUGIN_LIST={})).dwmx||(e.dwmx={}),(n=window.MILLENNIUM_PLUGIN_SETTINGS_STORE||(window.MILLENNIUM_PLUGIN_SETTINGS_STORE={})).dwmx||(n.dwmx={}),window.MILLENNIUM_SIDEBAR_NAVIGATION_PANELS||(window.MILLENNIUM_SIDEBAR_NAVIGATION_PANELS={}),function(e){e[e.CallServerMethod=0]="CallServerMethod"}(t||(t={}));let o=window.MILLENNIUM_PLUGIN_SETTINGS_STORE.dwmx,i="Millennium.Internal.IPC.[dwmx]";const r={DropDown:["string","number","boolean"],NumberTextInput:["number"],StringTextInput:["string"],FloatTextInput:["number"],CheckBox:["boolean"],NumberSlider:["number"],FloatSlider:["number"]};function a(e,n,o){return MILLENNIUM_BACKEND_IPC.postMessage(t.CallServerMethod,{pluginName:e,methodName:"__builtins__.__update_settings_value__",argumentList:{name:n,value:o}})}o.ignoreProxyFlag=!1,async function(){for(;"undefined"==typeof MainWindowBrowserManager;)await new Promise(e=>setTimeout(e,0));MainWindowBrowserManager?.m_browser?.on("message",(e,n)=>{if(e!==i)return;const{name:t,value:r}=JSON.parse(n);o.ignoreProxyFlag=!0,o.settingsStore[t]=r,a("dwmx",t,r),o.ignoreProxyFlag=!1})}();const _=e=>new Proxy(e,{set(e,n,t){if(!(n in e))throw new TypeError(`Property ${String(n)} does not exist on plugin settings`);const _=r[e[n].type],l=e[n]?.range;if(_.includes("number")&&"number"==typeof t&&(l&&(t=function(e,n,t){return Math.max(n,Math.min(t,e))}(t,l[0],l[1])),t||(t=0)),!_.includes(typeof t))throw new TypeError(`Expected ${_.join(" or ")}, got ${typeof t}`);return e[n].value=t,((e,n)=>{o.ignoreProxyFlag||(a("dwmx",e,n),"undefined"!=typeof MainWindowBrowserManager&&MainWindowBrowserManager?.m_browser?.PostMessage(i,JSON.stringify({name:e,value:n})))})(String(n),t),!0},get:(e,n)=>"__raw_get_internals__"===n?e:n in e?e[n].value:void 0});o.DefinePluginSetting=_,o.settingsStore=_({})}InitializePlugins();const __call_server_method__=(e,n)=>Millennium.callServerMethod("dwmx",e,n),__wrapped_callable__=e=>MILLENNIUM_API.callable(__call_server_method__,e);function PluginEntryPointMain(){
var PluginEntryPointMain = (() => {
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __export = (target, all) => {
    for (var name in all)
      __defProp(target, name, { get: all[name], enumerable: true });
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

  // work/millennium-stuff/plugins/dwmx-src/frontend/index.tsx
  var index_exports = {};
  __export(index_exports, {
    default: () => PluginMain
  });

  // globals:client
  var callable = __wrapped_callable__;
  var pluginSelf = window.PLUGIN_LIST.dwmx;
  var ConfirmModal = window.MILLENNIUM_API.ConfirmModal;
  var showModal = window.MILLENNIUM_API.showModal;

  // work/millennium-stuff/plugins/dwmx-src/frontend/index.tsx
  var originalOpen = window.open;
  var watchedWindows = /* @__PURE__ */ new WeakSet();
  var pendingPatch;
  function patchAfterShow() {
    if (pendingPatch !== void 0) return;
    pendingPatch = setTimeout(() => {
      pendingPatch = void 0;
      callable("PatchAllWindows")();
      setTimeout(() => {
        callable("PatchAllWindows")();
      }, 100);
    }, 0);
  }
  function watchWindow(popup) {
    if (!popup || watchedWindows.has(popup)) return;
    watchedWindows.add(popup);
    const nativeWindow = popup.SteamClient?.Window;
    for (const method of ["ShowWindow", "BringToFront"]) {
      const original = nativeWindow?.[method];
      if (typeof original !== "function") continue;
      nativeWindow[method] = function(...args) {
        const result = original.apply(this, args);
        patchAfterShow();
        return result;
      };
    }
    popup.document.addEventListener("visibilitychange", () => {
      if (!popup.document.hidden) patchAfterShow();
    });
    popup.addEventListener("focus", patchAfterShow);
  }
  var Patches = {
    TARGET_WINDOW_FLAG: [4114, 2],
    // Resizable | Composited | TransparentParentWindow: keeps windows
    // transparency-capable so the theme's translucent surfaces show the blur.
    NEW_WINDOW_FLAG: 4194576
  };
  window.open = function(url, target, features, replace) {
    if (!url) {
      return originalOpen(url, target, features, replace);
    }
    const parsedUrl = new URL(url);
    const queryParams = parsedUrl.searchParams;
    const windowFeature = "createflags";
    if (queryParams.has(windowFeature) && Patches.TARGET_WINDOW_FLAG.includes(parseInt(queryParams.get(windowFeature) || ""))) {
      queryParams.set(windowFeature, Patches.NEW_WINDOW_FLAG.toString());
      parsedUrl.search = queryParams.toString();
      url = parsedUrl.toString();
    }
    callable("PatchAllWindows")();
    const opened = originalOpen(url, target, features, replace);
    watchWindow(opened);
    for (const delay of [0, 100, 300, 800]) {
      setTimeout(() => {
        callable("PatchAllWindows")();
      }, delay);
    }
    return opened;
  };
  var ShowAlertMessage = (strTitle, strMessage) => showModal(/* @__PURE__ */ window.SP_REACT.createElement(ConfirmModal, { strTitle, strDescription: strMessage }));
  async function PluginMain() {
    pluginSelf.ShowAlertMessage = ShowAlertMessage;
    for (const delay of [500, 1500, 3e3, 6e3, 1e4]) {
      setTimeout(() => {
        callable("PatchAllWindows")();
      }, delay);
    }
    const manager = window.g_PopupManager;
    if (manager) {
      for (const popup of manager.GetPopups()) watchWindow(popup.m_popup);
      manager.AddPopupCreatedCallback((popup) => {
        watchWindow(popup.m_popup);
        patchAfterShow();
      });
    }
  }
  return __toCommonJS(index_exports);
})();

return PluginEntryPointMain;
}
function ExecutePluginModule(){let e=window.MILLENNIUM_PLUGIN_SETTINGS_STORE.dwmx;e.OnPluginConfigChange=function(n,t,o){n in e.settingsStore&&(e.ignoreProxyFlag=!0,e.settingsStore[n]=o,e.ignoreProxyFlag=!1)},MILLENNIUM_BACKEND_IPC.postMessage(0,{pluginName:"dwmx",methodName:"__builtins__.__millennium_plugin_settings_parser__"}).then(async n=>{"string"==typeof n.returnValue&&(e.ignoreProxyFlag=!0,e.settingsStore=e.DefinePluginSetting(Object.fromEntries(JSON.parse(atob(n.returnValue)).map(e=>[e.functionName,e]))),e.ignoreProxyFlag=!1);let t=PluginEntryPointMain();Object.assign(window.PLUGIN_LIST.dwmx,{...t,__millennium_internal_plugin_name_do_not_use_or_change__:"dwmx"});let o=await t.default();var i;o&&(i=o)&&void 0!==i.title&&void 0!==i.icon&&void 0!==i.content?(window.MILLENNIUM_SIDEBAR_NAVIGATION_PANELS.dwmx=o,MILLENNIUM_BACKEND_IPC.postMessage(1,{pluginName:"dwmx"})):console.warn("Plugin dwmx does not contain proper SidebarNavigation props and therefor can't be mounted by Millennium. Please ensure it has a title, icon, and content.")})}ExecutePluginModule();