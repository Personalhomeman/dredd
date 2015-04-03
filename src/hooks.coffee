
# READ THIS! Disclaimer:
# Do not add any functionality to this class unless you want to expose it to the Hooks API.
# This class is only an interface for users of Dredd hooks.

class Hooks
  constructor: ->
    @beforeHooks = {}
    @afterHooks = {}
    @transactions = {}
    @beforeAllHooks = []
    @afterAllHooks = []
    @beforeEachHooks = []
    @afterEachHooks = []

  before: (name, hook) =>
    @addHook(@beforeHooks, name, hook)

  after: (name, hook) =>
    @addHook(@afterHooks, name, hook)

  beforeAll: (hook) =>
    @beforeAllHooks.push hook

  afterAll: (hook) =>
    @afterAllHooks.push hook

  beforeEach: (hook) =>
    @beforeEachHooks.push hook

  afterEach: (hook) =>
    @afterEachHooks.push hook

  addHook: (hooks, name, hook) ->
    if hooks[name]
      hooks[name].push hook
    else
      hooks[name] = [hook]

  # This is not part of hooks API
  # This is here only because it has to be injected into sandboxed context
  dumpHooksFunctionsToStrings: () ->
    # prepare JSON friendly object
    toReturn = JSON.parse(JSON.stringify(@))

    # don't fiddle with transactions, they are not part of sandboxed sync API
    delete toReturn['transactions']

    hookTargets = Object.keys toReturn
    for hookTarget in hookTargets
      if Array.isArray @[hookTarget]
        for index, hookFunc of @[hookTarget]
          toReturn[hookTarget][index] = hookFunc.toString()

      else if typeof(@[hookTarget]) == 'object' and not Array.isArray(@[hookTarget])
        for transactionName, funcArray of @[hookTarget]
          for index, hookFunc of funcArray
            toReturn[hookTarget][transactionName][index] = hookFunc.toString()

    return toReturn

module.exports = Hooks
