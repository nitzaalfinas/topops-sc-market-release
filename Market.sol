// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver { 
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}


/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Market is Ownable, ERC1155Receiver {

    using SafeMath for uint256;
    
    string public name; 
    uint256 public feebp;
    address payable public admFeeAddr;
    address public aucExecutor;
    bool public contractPause;

    // address market 
    IERC1155 public nftAddress;

    // address mata uang 
    IERC20 public tokenAddress;

    // penanda jumlah dari list
    // nanti ini dibuat saja jadi private (hilangkan public)
    // dan buat sebuah function untuk mengambilnya yang hanya owner yang boleh
    uint256 public listCount;

    // 1. tipe sells fixed 
    struct SellFixObj {
        address seller;
        uint256 nftId;
        uint256 nftTotal;
        uint256 priceOne;
        bool executed;
    }

    // 2. tipe sells auction
    struct SellAucObj {
        address seller;
        uint256 endTime;
        uint256 nftId;
        uint256 nftTotal;
        uint256 priceAll;
        bool executed;
    }

    //      sell_id    tipe_obj
    mapping(uint256 => uint256) public sells;
    //      sell_id    
    mapping(uint256 => SellFixObj) public sellFixs;
    //      sell_id 
    mapping(uint256 => SellAucObj) public sellAucs;
    //      sell_id            rank       priceAll
    mapping(uint256 => mapping(uint256 => uint256)) public sellAucPrices;
    //      sell_id            rank       address
    mapping(uint256 => mapping(uint256 => address)) public sellAucAddressRanks;
    //      sell_id    price_awal
    mapping(uint256 => uint256) public sellAucStartPrices;
    //      sell_id    price_all_tertinggi
    mapping(uint256 => uint256) public sellAucHighBids;
    //      sell_id    address
    mapping(uint256 => address) public sellAucHighAddresses;
    //      sell_id    jumlah_auc
    mapping(uint256 => uint256) public sellAucCounts;

    mapping(address => int256) public repSellers;
    mapping(address => int256) public repBuyers;

    event EventSellFix(
        uint256 sellId,
        address seller,
        uint256 nftId,
        uint256 nftTotal, 
        uint256 priceOne 
    );

    event EventSellAuc(
        uint256 sellId,
        address seller, 
        uint256 endTime,
        uint256 nftId,
        uint256 nftTotal,
        uint256 priceAll  
    );

    event EventSellAucBid(
        uint256 sellId,
        address user, 
        uint256 priceAll
    );

    event EventDeleteSell(
        uint256 indexed sellId
    );

    constructor(
        string memory _name,
        address payable _admFeeAddr,
        address _aucExecutor,
        IERC1155 _nftAddress, 
        IERC20 _tokenAddress
    ) 
    public {
        name = _name;
        feebp = 185;           // 1.85% in basis points (parts per 10,000)
        admFeeAddr = _admFeeAddr;
        aucExecutor = _aucExecutor;
        contractPause = false;
        nftAddress = _nftAddress;           
        tokenAddress = _tokenAddress;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    modifier onlyAucExecutor {
        require(msg.sender == aucExecutor);
        _;
    }


    // --- only admin sections ------
    function setFeebp(uint256 _feebp) public onlyOwner {
        feebp = _feebp;        
    }

    function setAdmFeeAddr(address payable _address) public onlyOwner {
        admFeeAddr = _address;        
    }

    function setPause(bool _tf) public onlyOwner {
        contractPause = _tf;
    }

    function setAucExecutor(address _address) public onlyOwner {
        aucExecutor = _address;
    }

    // hanya ada di development
    // sementara ini digunakan untuk mengganti contract agar tidak capek reset database pada development
    // tapi dipertimbangkan juga untuk production
    function setNftAddress(IERC1155 _erc1155Address) public onlyOwner {
        nftAddress = _erc1155Address;
    }

    // hanya ada di development
    // sementara ini digunakan untuk mengganti contract agar tidak capek reset database pada development
    // tapi dipertimbangkan juga untuk production
    function setTokenAddress(IERC20 _erc20Address) public onlyOwner {
        tokenAddress = _erc20Address;
    }

    // --- only admin sections ------


    // --- bagian yang dipakai bersama-sama  -----------------------------
    // function _setReputationForCompleteSell(address _seller, address _buyer) private {
    //     repSellers[_seller] = repSellers[_seller] + 1;
    //     repBuyers[_buyer] = repBuyers[_buyer] + 1;   
    // }
    
    function _safeTwTransferFrom(IERC20 token, address sender, address recipient, uint256 amount) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }
    
    function _getTwAllowanceValue(IERC20 token, address owner, address spender) private view returns (uint256) {
        return token.allowance(owner, spender);
    }
    
    function _safeNftTransferFrom(address sender, address recipient, uint256 tokenId, uint256 amount) private {
        nftAddress.safeTransferFrom(sender, recipient, tokenId, amount, '');
    }
    // --- bagian yang dipakai bersama-sama  -----------------------------

    /*
    * @_nftId NFT ID 
    * @_price Harga satuan ketika listing
    */
    function setSell(
        uint256 _nftId,
        uint256 _nftTotal,
        uint256 _priceOne
    )
    public payable returns (uint256 _listId) {
        require(contractPause == false, "Contract pause");

        uint256 sellerNftBalance = nftAddress.balanceOf(msg.sender, _nftId);

        // jumlah token yang dipunya harus lebih besar atau sama dengan yang diinputkan 
        require(sellerNftBalance >= _nftTotal, "Not enough balance");

        // cek apakah contract ini dapat approved untuk erc1155 address
        require(nftAddress.isApprovedForAll(msg.sender, address(this)) == true, "Not approved");

        // transfer NFT dari buyer kepada diri sendiri (contract address ini)
        _safeNftTransferFrom(msg.sender, address(this), _nftId, _nftTotal);

        listCount = listCount + 1;

        // set menjadi tipe 1 (bukan auction)
        sells[listCount] = 1; 

        // simpan di collection sellFixs
        sellFixs[listCount] = SellFixObj(
            msg.sender,
            _nftId,
            _nftTotal,
            _priceOne,
            false
        );

        emit EventSellFix(
            listCount, 
            msg.sender, 
            _nftId, 
            _nftTotal, 
            _priceOne
        );

        return listCount;
    }

    /**
    * Keterangan:
    * Hanya khusus digunakan untuk update harga.
    * Jika ingin update jumlah NFT juga, harus dicancel dan dimasukkan data baru
    * Ini juga bolehnya diupdate jika adalah fix price
    *
    * Negative case:
    * - address bukan pemilik mencoba update
    */
    function updateSellPrice(uint256 _listId, uint256 _priceOne) public returns (bool) {
        require(contractPause == false, "Contract pause");

        // yang bisa update hanya dia saja
        require(msg.sender == sellFixs[_listId].seller, "You can not update");  

        // hanya boleh update dengan type 1 (sell fix)
        require(sells[_listId] == 1, "Wrong sell type");

        // hanya boleh diupdate jika executed == false 
        require(sellFixs[_listId].executed == false, "Sell executed");

        // update harga 
        sellFixs[_listId].priceOne = _priceOne;

        return true;
    }

    /**
    * Test untuk negative case: 
    * - address bukan pemilik meng-cancel ini
    */
    function cancelSell(uint256 _listId) public returns (bool) {
        require(contractPause == false, "Contract pause");

        // yang bisa cancel hanya dia saja
        require(msg.sender == sellFixs[_listId].seller, "You can't cancel");  

        // hanya boleh cancel dengat type 1 (sell fix)
        require(sells[_listId] == 1, "Wrong sell type");

        // hanya boleh diupdate jika executed == false 
        require(sellFixs[_listId].executed == false, "Sell executed");

        // catat sebagai executed
        sellFixs[_listId].executed = true;
        
        // kembalikan NFT dia 
        _safeNftTransferFrom(address(this), msg.sender, sellFixs[_listId].nftId, sellFixs[_listId].nftTotal);

        // nft yang tersimpan dijadikan 0 karena sudah dikembalikan
        sellFixs[_listId].nftTotal = 0;

        return true;
    }

    function setSellAuction(
        uint256 _nftId,
        uint256 _nftTotal,
        uint256 _priceAll,
        uint256 _endTime
    )
    public payable returns (uint256 _listId) {
        require(contractPause == false, "Contract pause");

        uint256 sellerNftBalance = nftAddress.balanceOf(msg.sender, _nftId);

        // harus punya tokennya 
        require(sellerNftBalance >= _nftTotal, "You don't have NFT");

        // cek apakah contract ini dapat approved untuk erc1155 address
        require(nftAddress.isApprovedForAll(msg.sender, address(this)) == true, "Not approved");

        // waktu harus lebih besar dari waktu minting
        // cek hari ini 
        // https://ethereum.stackexchange.com/questions/9858/solidity-is-there-a-way-to-get-the-timestamp-of-a-transaction-that-executed
        // hari_ini < hari_surat
        // sebelumnya ini pakai `now`, tetapi ini deprecated. Ini diminta ganti dengan block.timestamp
        require(block.timestamp < _endTime, "End time must be bigger");

        // transfer token kepada diri sendiri (contract address ini)
        _safeNftTransferFrom(msg.sender, address(this), _nftId, _nftTotal);

        listCount = listCount + 1;

        // set menjadi tipe 2 (auction)
        sells[listCount] = 2; 

        // simpan di collection sellAucs
        sellAucs[listCount] = SellAucObj(
            msg.sender,
            _endTime,
            _nftId,
            _nftTotal,
            _priceAll,
            false
        );

        // harga dimasukkan sekarang berarti adalah harga tertinggi 
        // sehingga harus dicatatkan menjadi harga tertinggi 
        sellAucHighBids[listCount] = _priceAll;

        // otomatis juga ini menjadi harga awal 
        sellAucStartPrices[listCount] = _priceAll;

        // catatkan juga address yang tertinggi ini 
        sellAucHighAddresses[listCount] = msg.sender;

        // catatkan auction Count untuk id ini 
        sellAucCounts[listCount] = 0;

        emit EventSellAuc(
            listCount, 
            msg.sender,
            _endTime,
            _nftId, 
            _nftTotal, 
            _priceAll
        );

        return listCount;
    }


    function setBid(uint256 _id, uint256 _priceAll) public payable {
        require(contractPause == false, "Contract pause");

        // cek dulu apakah market memang tipe auction 
        require(sells[_id] == 2, "Not auction");

        // cegah set bid ketika auction sudah berakhir
        require(sellAucs[_id].endTime > block.timestamp, "Auction end");

        // jumlah yang dimasukkan harus lebih besar dari yang tertinggi saat ini  
        require(_priceAll > sellAucHighBids[_id], "Bid too low");

        // cek allowance token 
        require(tokenAddress.allowance(msg.sender, address(this)) >= _priceAll, "Allowance too low" );

        // ambil token yang sudah di allowance sebesar _priceAll 
        _safeTwTransferFrom(tokenAddress, msg.sender, address(this), _priceAll);

        // catatkan bahwa yang tertinggi sekarang adalah yang baru dimasukkan 
        sellAucHighBids[_id] = _priceAll;

        // catatkan adddress tertinggi adalah address yang baru dimasukkan
        sellAucHighAddresses[_id] = msg.sender;

        // jumlah baru auction untuk id ini
        uint256 newAucCount = sellAucCounts[_id] + 1;
        sellAucCounts[_id] = newAucCount; 

        // setelah jumlah baru dicatatkan, maka ditambahkan pencatatan 
        // child 
        sellAucPrices[_id][newAucCount] = _priceAll;
        // rank based on address 
        sellAucAddressRanks[_id][newAucCount] = msg.sender;
        
        // jika count bid pada id sell ini lebih dari 1, maka token yang tersimpan dikembalikan
        // karena jika masih 0, maka itu adalah seller
        // jika masih 1, maka ini adalah bidder pertama
        // jika besar dari 1 atau dikatakan 2, 3, 4, maka yang mempunyai id sebelumnya wajib dipulangkan
        if(newAucCount > 1) {
            uint256 idSebelum = newAucCount - 1;            
            tokenAddress.transfer(sellAucAddressRanks[_id][idSebelum], sellAucPrices[_id][idSebelum]);
        }
    }

    
    /*
    *
    * @_id adalah ID dari sells
    * @_amount adalah jumlah NFT yang diinginkan
    */
    function swap(uint256 _id, uint256 _amount, uint256 _priceOne) public payable {
        require(contractPause == false, "Contract pause");

        // atur variable 
        address seller = sellFixs[_id].seller;
        address buyer = msg.sender;

        // jumlah yang diinginkan harus lebih kecil dari jumlah yang ada di market 
        require(sellFixs[_id].nftTotal >= _amount, "Number of requests not met");

        // cegah mendapatkan serangan pada update sell.
        // Karena serangan bisa dilakukan dengan mengupdate harga.
        // Keterangan: Jika block untuk swap ter-eksekusi pada blockchain terlambat, maka harga akan update terlebih dahulu
        //     Untuk pencegahan user mendapatkan harga sesuai dengan ekspektasinya, maka disini harus dicegah
        //     ketika harga berubah.
        require(sellFixs[_id].priceOne == _priceOne, "Sell price has changed");

        // kalkulasi jumlah yang harus dibayarkan oleh buyer 
        uint256 total = _amount.mul(sellFixs[_id].priceOne);

        // cek apakah buyer memberikan token allowance sebesar total 
        require(tokenAddress.allowance(buyer, address(this)) >= total, "Token allowance too low");

        // kalkulasi fee  
        uint256 tokenFeeForAdmin = total.mul(feebp).div(10000); // persentase

        // jumlah token erc20 yang akan dikirimkan kepada seller 
        uint256 tokenForSeller = total.sub(tokenFeeForAdmin);

        // 2. buyer mengirimkan ERC20 kepada seller
        _safeTwTransferFrom(tokenAddress, buyer, seller, tokenForSeller);

        // 3. admin mendapatkan fee ERC20 
        _safeTwTransferFrom(tokenAddress, buyer, admFeeAddr, tokenFeeForAdmin);

        // 4. jika hasil akhir seller token jadi 0, maka ini harus di delisting 
        if(sellFixs[_id].nftTotal == _amount) {
        
            // dikurangi sehingga hasilnya 0.
            // pada tempat ini kita jadikan saja paksa nilainya langsung jadi 0
            // karena nftTotal sama dengan _amount yang diminta
            sellFixs[_id].nftTotal = 0;

            // catat sebagai executed
            sellFixs[_id].executed = true;
            
            // simpan dalam log 
            emit EventDeleteSell( _id );
        }
        else {
            // hasil harus dikurangkan dan disimpan kembali dalam blockchain 
            sellFixs[_id].nftTotal = (sellFixs[_id].nftTotal).sub(_amount);
        }
        
        // 1. sc ini kirim NFT kepada buyer 
        _safeNftTransferFrom(address(this), buyer, sellFixs[_id].nftId, _amount);
    }

    function swapAuc(uint256 _id) public payable onlyAucExecutor  {
        require(contractPause == false, "Contract pause");
        
        // cek dulu apakah market memang tipe auction 
        require(sells[_id] == 2, "Not auction");

        // eksekusi hanya bisa dilakukan setelah auction expire
        require(sellAucs[_id].endTime < block.timestamp, "Auction is not over yet");

        // hanya boleh di eksekusi 1x
        require(sellAucs[_id].executed == false, "Has been executed");

        if(sellAucCounts[_id] > 0) {
            // jika ada yang nge-bid, maka tetapkan pemenang dan kirim NFT
            // penjual disini dapat token ERC20

            // atur seller
            address seller = sellAucs[_id].seller;

            // --- buyer adalah pemenang. ---
            // 1. Jumlah yang submit berarti adalah id terakhir atau dengan bid terbesar 
            uint256 indexWinner = sellAucCounts[_id];

            // 2. cari tahu address winner
            address buyer = sellAucAddressRanks[_id][indexWinner];
            // --- buyer adalah pemenang. ---

            // harga semua nft yang di auction kan 
            uint256 priceAllNft = sellAucPrices[_id][indexWinner];

            // kalkulasi fee  
            uint256 tokenFeeForAdmin = priceAllNft.mul(feebp).div(10000); // persentase

            // jumlah token erc20 yang akan dikirimkan kepada seller 
            uint256 tokenForSeller = priceAllNft.sub(tokenFeeForAdmin);

            // 1. sc ini kirim NFT kepada buyer 
            _safeNftTransferFrom(address(this), buyer, sellAucs[_id].nftId, sellAucs[_id].nftTotal);
            
            // 2. buyer mengirimkan ERC20 kepada seller
            // tetapi karena token buyer sudah disimpan, maka dikirim dari smartcontract saja
            tokenAddress.transfer(seller, tokenForSeller);

            // 3. admin mendapatkan fee ERC20 dari buyer
            // tetapi karena boken buyer sudah ada dalam smartcontract, maka dikirim dari smartcontract saja
            tokenAddress.transfer(admFeeAddr, tokenFeeForAdmin);

        }
        else if (sellAucCounts[_id] == 0) {
            // jika gak ada yang nge-bid
            
            _safeNftTransferFrom(address(this), sellAucs[_id].seller, sellAucs[_id].nftId, sellAucs[_id].nftTotal);       
        }

        // catatkan bahwa ini telah di eksekusi
        sellAucs[_id].executed = true;
    }
}
