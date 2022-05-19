pragma solidity ^0.5.0;

contract BeaverFactory {

  /*
  *   A new cat is born
  */
  event Birth(address owner, uint256 beaverId, uint256 mumId, uint256 dadId, uint256 genes);

  /*
  *   A cat has been transfer
  */
  event Transfer(address from, address to, uint256 tokenId);

  /*
  *   Here we will use the same structure as the original crypto beavers game
  *   As it fit exactly into two bit words
  */
  struct Beaver {

      uint256 genes;
      uint64 birthTime;
      uint32 mumId;
      uint32 dadId;
      uint16 generation;
  }

  Beaver[] beavers;

  mapping (uint256 => address) public beaverIndexToOwner;
  mapping (address => uint256) ownershipTokenCount;

  // Add a list of approved beavers, that are allowed to be transfered
  mapping (uint256 => address) public beaverIndexToApproved;

  function _createBeaver(
      uint256 _mumId,
      uint256 _dadId,
      uint256 _generation,
      uint256 _genes,
      address _owner
  )
      internal
      returns (uint)
  {

    Beaver memory _beaver = Beaver({
        genes: _genes,
        birthTime: uint64(now),
        mumId: uint32(_mumId),
        dadId: uint32(_dadId),
        generation: uint16(_generation)
    });

    uint256 newKittenId = beavers.push(_beaver) - 1;

    // It's probably never going to happen, 4 billion cats is A LOT, but
    // let's just be 100% sure we never let this happen.
    require(newKittenId == uint256(uint32(newKittenId)));

    // emit the birth event
    emit Birth(
        _owner,
        newKittenId,
        uint256(_beaver.mumId),
        uint256(_beaver.dadId),
        _beaver.genes
    );

    // This will assign ownership, and also emit the Transfer event as
    // per ERC721 draft
    _transfer(address(0), _owner, newKittenId);
    return newKittenId;
  }

  function _transfer(address _from, address _to, uint256 _tokenId) internal {

    // Since the number of kittens is capped to 2^32 we can't overflow this
    ownershipTokenCount[_to]++;
    // transfer ownership
    beaverIndexToOwner[_tokenId] = _to;

    if (_from != address(0)) {
        ownershipTokenCount[_from]--;

        delete beaverIndexToApproved[_tokenId];
    }

    // Emit the transfer event.
    emit Transfer(_from, _to, _tokenId);
  }
}
