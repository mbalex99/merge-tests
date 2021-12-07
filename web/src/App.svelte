<script lang="ts">
  import { Ditto, init, Document, LiveQuery } from "@dittolive/ditto";

  import Highlight from "svelte-highlight";
  import typescript from "svelte-highlight/src/languages/typescript";
  import github from "svelte-highlight/src/styles/github";
  import _ from "lodash";
  import { each } from "svelte/internal";
  import { fade } from "svelte/transition";
  import fadeScale from "./fadeScale";
  import { cubicInOut } from "svelte/easing";
  import classNames from "classnames";
  let ditto: Ditto | undefined;
  let initErrorMessage: string | undefined;
  let initSuccessMessage: string | undefined;

  let collectionName = "cars";
  let docID: string = "123abc";

  let currentDocumentJSONString: string;

  let liveQuery: LiveQuery;

  interface Action {
    id: string;
    text: string;
  }

  let actions: Action[] = [];

  let isSyncEnabled = false;

  (async () => {
    try {
      await init();
      const appID = "600f455f-a1f0-403d-8042-b746b2c581ab";
      ditto = new Ditto(
        {
          type: "onlinePlayground",
          appID: appID,
          enableDittoCloudSync: true,
        },
        "ditto"
      );
      ditto.setLicenseToken(
        "o2d1c2VyX2lka21lcmdlLXRlc3RzZmV4cGlyeXgYMjAyMi0wMy0zMVQyMzo1OTo1OS4yMzhaaXNpZ25hdHVyZXhYd2xISWc5R2RrSHRPeW8rcnIxd3VwWklmclJPekVPa2NicWR5cVZvd2hFdzRncGcrZFhPWWp5aEVVZDlNQzQwUWQyYVoyVlFsUzZYMjhUeU54R1c5c2c9PQ=="
      );
      initSuccessMessage = `Successfully loaded Ditto.wasm for appID: ${appID} siteID: ${ditto.siteID}`;
      bindLiveQuery();
      beginSync();
    } catch (err) {
      initErrorMessage = err.toString();
    }
  })();

  function beginSync() {
    try {
      ditto.tryStartSync();
      isSyncEnabled = true;
    } catch (err) {
      initErrorMessage = err.toString();
      isSyncEnabled = false;
    }
  }

  function endSync() {
    ditto.stopSync();
    isSyncEnabled = false;
  }

  function toggleSync() {
    if (isSyncEnabled) {
      endSync();
    } else {
      beginSync();
    }
  }

  function bindLiveQuery() {
    liveQuery?.stop();
    liveQuery = ditto.store
      .collection(collectionName)
      .findByID(docID)
      .observe((doc) => {
        if (doc) {
          // I have to call a getter on a property
          // to stringify the value: https://github.com/getditto/ditto/issues/4625
          console.log(doc.name);
          currentDocumentJSONString = JSON.stringify(
            doc["@ditto.value"],
            null,
            4
          );
        } else {
          currentDocumentJSONString = "null";
        }
      });
  }

  async function insert() {
    let payload = {
      _id: docID,
      name: "Honda",
      isSold: true,
      tags: ["a", "b", "c"],
    };
    await ditto!.store.collection(collectionName).insert(payload);
    actions = _.concat(
      {
        id: _.uniqueId(),
        text: `ditto.store.collection("${collectionName}").insert(${JSON.stringify(
          payload,
          null,
          4
        )})`,
      },
      actions
    );
  }

  async function insertOverwrite() {
    let payload = {
      _id: docID,
      name: `Honda-overwritten-${_.random(0, 999)}`,
      newProperty: _.random(0, 999),
      isSold: true,
      tags: ["a", `b-overwritten-${_.random(0, 999)}`, "c"],
    };
    await ditto!.store
      .collection(collectionName)
      .insert(payload, { writeStrategy: "overwrite" });

    actions = _.concat(
      {
        id: _.uniqueId(),
        text: `ditto.store.collection("${collectionName}").insert(${JSON.stringify(
          payload,
          null,
          4
        )}, {writeStrategy: 'overwrite'})`,
      },
      actions
    );
  }

  async function insertMerge() {
    let payload = {
      _id: docID,
      name: `Honda-overwritten-${_.random(0, 999)}`,
      isSold: true,
      tags: [
        "a",
        `b-merge-overwritten-${_.random(0, 999)}`,
        "c",
        `new-${_.random(0, 999)}`,
      ],
    };
    await ditto!.store
      .collection(collectionName)
      .insert(payload, { writeStrategy: "overwrite" });

    actions = _.concat(
      {
        id: _.uniqueId(),
        text: `ditto.store.collection("${collectionName}").insert(${JSON.stringify(
          payload,
          null,
          4
        )}, {writeStrategy: 'merge'})`,
      },
      actions
    );
  }

  async function remove() {
    await ditto!.store.collection(collectionName).findByID(docID).remove();
    actions = _.concat(
      {
        id: _.uniqueId(),
        text: `ditto.store.collection("${collectionName}").findByID("${docID}").remove()`,
      },
      actions
    );
  }
</script>

<main class="container">
  <h1>Ditto Merge Tests</h1>
  {#if initErrorMessage}
    <div class="alert alert-danger" role="alert">
      {initErrorMessage}
    </div>
  {/if}

  <div class="row">
    <div class="col">
      <div
        class={classNames("alert", {
          "alert-info": isSyncEnabled,
          "alert-warning": !isSyncEnabled,
        })}
        role="alert"
      >
        {isSyncEnabled ? "YES, We are syncing!" : "NO, We are not syncing!"}
      </div>
    </div>
    <div class="col">
      <button on:click={toggleSync}>
        {isSyncEnabled ? "Stop" : "Start"}
      </button>
    </div>
  </div>

  <div class="row">
    <div class="col">
      <div class="input-group mb-3">
        <span class="input-group-text">Collection Name</span>
        <input
          class="form-control"
          type="text"
          bind:value={collectionName}
          on:input={bindLiveQuery}
        />
      </div>
      <div class="input-group mb-3">
        <span class="input-group-text">DocID</span>
        <input
          class="form-control"
          type="text"
          bind:value={docID}
          on:input={bindLiveQuery}
        />
      </div>
    </div>
    <div class="col font-monospace">
      <button class="btn btn-primary" on:click={insert}> insert </button>
      <button class="btn btn-danger" on:click={remove}> remove </button>
      <button class="btn btn-info" on:click={insertOverwrite}>
        insert(.overwrite)
      </button>
      <button class="btn btn-info" on:click={insertMerge}>
        insert(.merge)
      </button>
    </div>
  </div>

  <div class="row">
    <div class="col-md-12">
      <h4>
        Live Query for docId: <span class="text-primary font-bold">{docID}</span
        >
      </h4>
      <div class="card">
        <div class="card-body">
          {#if currentDocumentJSONString}
            <Highlight language={typescript} code={currentDocumentJSONString} />
          {/if}
        </div>
      </div>
    </div>
    <div class="col-md-6 d-none">
      <h4>Actions</h4>
      {#each actions as action (action.id)}
        <div
          class="card"
          transition:fadeScale={{
            delay: 0,
            duration: 250,
            easing: cubicInOut,
            baseScale: 0.5,
          }}
        >
          <div class="card-body">
            <Highlight language={typescript} code={action.text} />
          </div>
        </div>
      {/each}
    </div>
  </div>
</main>

<svelte:head>
  {@html github}
</svelte:head>

<style>
  @import "https://cdn.jsdelivr.net/npm/bootstrap@5.1.0/dist/css/bootstrap.min.css";
</style>
