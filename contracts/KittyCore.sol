import "./utils/Ownable.sol";
import "./BeaverMarketPlace.sol";

pragma solidity ^0.5.0;

contract BeaverCore is Ownable, BeaverMarketPlace {

  uint256 public constant CREATION_LIMIT_GEN0 = 10;

  // Counts the number of cats the contract owner has created.
  uint256 public gen0Counter;

  constructor() public {
    // We are creating the first beaver at index 0  
    _createBeaver(0, 0, 0, uint256(-1), address(0));
  }

/*
*       we get a 
*
*       Basic binary operation
*
*       >>> '{0:08b}'.format(255 & 1)
*       '00000001'
*       >>> '{0:08b}'.format(255 & 2)
*       '00000010'
*       >>> '{0:08b}'.format(255 & 4)
*       '00000100'
*       >>> '{0:08b}'.format(255 & 8)
*       '00001000'
*       >>> '{0:08b}'.format(255 & 16)
*       '00010000'
*       >>> '{0:08b}'.format(255 & 32)
*       '00100000'
*       >>> '{0:08b}'.format(255 & 64)
*       '01000000'
*       >>> '{0:08b}'.format(255 & 128)
*       '10000000'
*
*       So we use a mask on our random number to check if we will use the mumID or the dadId
*
*       For example 205 is 11001101 in binary So
*       mum - mum - dad -dad -mum - mum - dad - mum
*
*/
  function Breeding(uint256 _dadId, uint256 _mumId) public {
      require(_owns(msg.sender, _dadId), "The user doesn't own the token");
      require(_owns(msg.sender, _mumId), "The user doesn't own the token");

      require(_mumId != _dadId, "The cat can't reproduce himself");

      ( uint256 Dadgenes,,,,uint256 DadGeneration ) = getBeaver(_dadId);

      ( uint256 Mumgenes,,,,uint256 MumGeneration ) = getBeaver(_mumId);

      uint256 geneKid;
      uint256 [8] memory geneArray;
      uint256 index = 7;
      uint8 random = uint8(now % 255);
      uint256 i = 0;
      
      for(i = 1; i <= 128; i=i*2){

          /* We are */
          if(random & i != 0){
              geneArray[index] = uint8(Mumgenes % 100);
          } else {
              geneArray[index] = uint8(Dadgenes % 100);
          }
          Mumgenes /= 100;
          Dadgenes /= 100;
        index -= 1;
      }
     
      /* Add a random parameter in a random place */
      uint8 newGeneIndex =  random % 7;
      geneArray[newGeneIndex] = random % 99;

      /* We reverse the DNa in the right order */
      for (i = 0 ; i < 8; i++ ){
        geneKid += geneArray[i];
        if(i != 7){
            geneKid *= 100;
        }
      }

      uint256 kidGen = 0;
      if (DadGeneration < MumGeneration){
        kidGen = MumGeneration + 1;
        kidGen /= 2;
      } else if (DadGeneration > MumGeneration){
        kidGen = DadGeneration + 1;
        kidGen /= 2;
      } else{
        kidGen = MumGeneration + 1;
      }

      _createBeaver(_mumId, _dadId, kidGen, geneKid, msg.sender);
  }


  function createBeaverGen0(uint256 _genes) public onlyOwner {
    require(gen0Counter < CREATION_LIMIT_GEN0);

    gen0Counter++;

    // Gen0 have no owners they are own by the contract
    uint256 tokenId = _createBeaver(0, 0, 0, _genes, msg.sender);
    setOffer(0.2 ether, tokenId);
  }

  function getBeaver(uint256 _id)
    public
    view
    returns (
    uint256 genes,
    uint256 birthTime,
    uint256 mumId,
    uint256 dadId,
    uint256 generation
  ) {
    Beaver storage beaver = beavers[_id];

    require(beaver.birthTime > 0, "the beaver doesn't exist");

    birthTime = uint256(beaver.birthTime);
    mumId = uint256(beaver.mumId);
    dadId = uint256(beaver.dadId);
    generation = uint256(beaver.generation);
    genes = beaver.genes;
  }
}