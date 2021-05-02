pub contract PinataPartyContract {
    pub resource NFT {
        pub let id: UInt64
        init(initID: UInt64) {
            self.id = initID
        }
    }
    pub resource interface NFTReceiver {
        pub fun deposit(token: @NFT, metadata: {String : String})
        pub fun getIDs(): [UInt64]
        pub fun idExists(id: UInt64): Bool
        pub fun getMetadata(id:UInt64) : {String : String}
    }
    pub resource Collection: NFTReceiver {
        pub var ownedNFT: @{UInt64: NFT}
        pub var metadataObjs: {UInt64: {String : String}}

        init() {
            self.ownedNFT <- {}
            self.metadataObjs = {}
        }

        pub fun withdraw(withdrawID: UInt64): @NFT {
            let token <- self.ownedNFT.remove(key: withdrawID)!

            return <-token
        }
        
        pub fun deposit(token: @NFT, metadata: {String : String}){
            self.ownedNFT[token.id] <-! token
        }

        pub fun idExists(id: UInt64): Bool {
            return self.ownedNFT[id] != nil
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFT.keys
        }

        pub fun updateMetadata(id: UInt64, metadata: {String: String}) {
            self.metadataObjs[id] = metadata
        }

        pub fun getMetadata(id: UInt64): {String : String} {
            return self.metadataObjs[id]!
        }

        destroy() {
            destroy self.ownedNFT
        }

    }

    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    pub resource NFTMinter {
        pub var idCount: UInt64

        init() {
            self.idCount = 1
        }

        pub fun mintNFT(): @NFT {
            var newNFT <- create NFT(initID: self.idCount)

            self.idCount = self.idCount + 1 as UInt64

            return <- newNFT
        }
    }

    init() {
        self.account.save(<-self.createEmptyCollection(), to: /storage/NFTCollection)
        self.account.link<&{NFTReceiver}>(/public/NFTReceiver, target: /storage/NFTCollection)
        self.account.save(<-create NFTMinter(), to: /storage/NFTMinter)
    }
}