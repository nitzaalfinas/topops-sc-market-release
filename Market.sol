// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// SEBELUM DEPLOY, YANG IERC1155 HARUS DIGANTI JADI IBEP1155
// IERC20 HARUS DIGANTI JADI IBEP20
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.1/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.1/contracts/token/ERC1155/IERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.1/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.1/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.3.1/contracts/access/Ownable.sol";

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
