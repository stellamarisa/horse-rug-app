export DBConfig = {
  name: 'MyDB',
  version: 1,
  objectStoresMeta: [
    {
      store: 'Pferd',
      storeConfig: { keyPath: 'id', autoIncrement: true },
      storeSchema: [
        { name: 'name', keypath: 'name', options: { unique: false } },
        { name: 'sensibility', keypath: 'sensibility', options: { unique: false } }
        { name: 'foto', keypath: 'foto', options: { unique: false } }
      ]
    },
    {
      store: 'Decke',
      storeConfig: { keyPath: 'id', autoIncrement: true },
      storeSchema: [
        { name: 'brand', keypath: 'brand', options: { unique: false } },
        { name: 'filling', keypath: 'filling', options: { unique: false } }
        { name: 'color', keypath: 'color', options: { unique: false } }
      ]
    }
  ]
}