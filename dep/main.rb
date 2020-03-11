# 于b4948f0c9882a10197fd317c8f9fd9ef90dd7588之后删除多余代码
# build in
require 'logger'
require 'open-uri'
#require 'md5'
#require 'digest/md5'
require 'openssl'

require 'mysql'

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '.'))

require 'config'
require 'lib/bitcoin_rpc'
require 'db/token_dao'
require 'db/txs_dao'
require 'db/baseinfo_dao'

#使用教程
# 1.配置log目录路径
# 2.配置签名私钥
# 3.配置接收平台地址url
# 4.配置数据库
# 5.运行

#*****************************************************  开始执行主程序  **************************************************
if $0 == __FILE__

  #输出到文件，统一填写绝对路径，文件名log.out 不需要再写绝对路径, 文件夹在哪里就是哪里.
  #$logger = Logger.new(($log_path + 'main.log').to_s)
  time = Time.new
  period = 0
  if time.day <= 7
  	period = 1
  else
  	period = time.day / 7
  end
  $logPeriod = time.strftime("%Y-%m") +"-"+period.to_s+"week"
  $log_file = $logPeriod + '_main.log'
  $log_path = Pathname.new(File.dirname(__FILE__)).realpath + 'log'
  $logger =  Logger.new(($log_path +$log_file).to_s)

  $logger.info("** START THE PROGRAM **")

  #获取数据库基本参数信息
  baseinfos = get_baseinfo_tb
  $lastScanBlock = baseinfos['lastScanBlock']
  $usersMax = baseinfos['usersMax']
  $lastLoadBlock = baseinfos['lastLoadBlock']
  $isLoad = baseinfos['isLoad']
  $isScan = baseinfos['isScan']
  $isPost = baseinfos['isPost']
  $rpcHost = baseinfos['rpcHost']
  $rpcPort = baseinfos['rpcPort']

  #构建币RPC链接地址
  $rpcAddr = $rpc_addr % [$rpcHost, $rpcPort.to_s]
  #$logger.info("rpcAddr: " + $rpcAddr)
  coinrpc = BitcoinRPC.new($rpcAddr)

  #获取当前区块高度
  $latestBlockHeightx = coinrpc.eth_blockNumber()
  $latestBlockHeight = $latestBlockHeightx.hex
  $logger.info("latestBlockHeight: " + $latestBlockHeight.to_s)

  # 加载现有的token币种, 减少数据库访问量
  $tokens = get_token_db
  if $tokens.size == 0
    # 如果数据库中没有任何一种代币, 退出程序
    $logger.warn('[WARNING] Token table is not data')
    exit(1)
  end
  # 获取tokens中所有COINTYPE与SYMBOL对应
  $token_type = {}
  $tokens.values.each do | _each |
    $token_type[_each['COINTYPE']] = _each['SYMBOL']
  end
  $to_addr = '' # 全局临时变量, 用于从tokens中获取相应信息
  # $logger.debug("[DEBUG] tokens is #{$tokens}")
  # $logger.debug("[DEBUG] token_type is #{$token_type}")

  #$logger.info("usersMax: " + $usersMax.to_s)
  #$logger.info("lastLoadBlock: " + $lastLoadBlock.to_s)
  #$logger.info("lastScanBlock: " + $lastScanBlock.to_s)
  #$logger.info("isLoad: " + $isLoad)
  #$logger.info("isScan: " + $isScan)
  #$logger.info("isPost: " + $isPost)

  #test marktodo
  #$latestBlockHeight = 4002514 #test
  $logger.debug('[DEBUG] *** 加载区块链交易开始 ***')
  #*****************************************************  遍历区块链，加载交易  **************************************************
  #加载该区间内的所有区块的所有交易
  $iHeight = $lastLoadBlock +1
  #$iHeight = 4002514 #test

  while ($isLoad.to_i == 1) && ( $iHeight <= $latestBlockHeight) do

    $logger.info("load_blockHeight: " + $iHeight.to_s)

    #获取当前区块交易数量
    $blockTransactionCount_f = coinrpc.eth_getBlockTransactionCountByNumber('0x' + $iHeight.to_s(16))

    $blockTransactionCount = $blockTransactionCount_f.hex
    $logger.info("load_blockTxCount: " + $blockTransactionCount.to_s)

    #获取当前区块详细信息，包括所有交易
    $blockInfo = coinrpc.eth_getBlockByNumber('0x' + $iHeight.to_s(16),true)
    $blocktxs = $blockInfo['transactions']
    #$logger.info("blockInfo: " + $blockInfo.to_s)
    #$logger.info("blocktxs: "  + $blocktxs.to_s)

    #循环依次向数据库填写当前区块的每一笔交易
    $iTx = 0;
    while $iTx < $blockTransactionCount do

      $txHash = $blocktxs[$iTx]['hash']
      $blockHash = $blocktxs[$iTx]['blockHash']
      $blockNumber = $blocktxs[$iTx]['blockNumber'].hex
      $from = $blocktxs[$iTx]['from']
      $gasLimit = $blocktxs[$iTx]['gas'].hex
      $gasPrice = $blocktxs[$iTx]['gasPrice'].hex
      $nonce = $blocktxs[$iTx]['nonce'].hex
      $to_addr = $to = $blocktxs[$iTx]['to']
      $transactionIndex = $blocktxs[$iTx]['transactionIndex'].hex
      $value = $blocktxs[$iTx]['value']
      $transactionIndex = $blocktxs[$iTx]['transactionIndex'].hex
      $ether = $value.hex.to_f / $wei

      #构造合约的交易，to为 nil ,会导致下面语句类型转换错误
      # 并且当$to为nil时, 不会出现任何处理结果
      if $to == nil
        $iTx += 1
        next
      end

=begin
      $logger.info("txIndex: " + $transactionIndex.to_s)
      $logger.info("txHash: " + $txHash)
      $logger.info("blockHash: " + $blockHash)
      $logger.info("blockNumber: " + $blockNumber.to_s)
      $logger.info("from: " + $from)
      $logger.info("gas: " + $gasLimit.to_s)
      $logger.info("gasPrice: " + $gasPrice.to_s)
      $logger.info("nonce: " + $nonce.to_s)
      $logger.info("to: " + $to)
      $logger.info("transactionIndex: " + $transactionIndex.to_s)
      $logger.info("value: " + $value)
      $logger.info("ether: " + $ether.to_s)
=end

     #注：如果不处理合约，可以直接去掉下面的代码     
      $inputData = $blocktxs[$iTx]['input']
      $assetType = "0" #币种类型，默认ETH
      # ***************************************  开始处理合约 新方式 *********************************
      if (($tokens.keys.include?$to.downcase) && ($inputData.length > 50))
        $methodId    = $inputData[0,10]
        $innerAddrTo = $inputData[34,40]
        $innerValue  = $inputData[-24,24] #这个要根据资产的小数位数来定，应该想办法去掉前边所有连续的0
        #$logger.info("blockNumber: " + $blockNumber.to_s)
        #$logger.info("txHash: " + $txHash)
        #$logger.info("inputData: " + $inputData)
        #$logger.info("methodId: "  + $methodId)
        #$logger.info("innerAddrTo: " + $innerAddrTo)
        #$logger.info("innerValue: "  + $innerValue)

        #确定是转账交易
        if ($METHODID_TOKEN_TRANSFER == $methodId) && ($innerAddrTo != nil)

          #通过对比区块前后余额以判断是否真的充值成功
          $functionAbi = '0x70a08231000000000000000000000000'
          $senddata = $functionAbi + $innerAddrTo #地址要去掉0x前缀

          #构造发送交易
          $txhash = {'from' => '0x' + $innerAddrTo,
                     'to' => $to,
                     'gas' => '0xea60',
                     'gasPrice' => '0x4e3b29200',
                     'value' => '0x0',
                     'data' => $senddata
          }
          $logger.info("txhash: " + $txhash.to_s)

          #查余额
          $amount_pre = 0
          $amount_cur = 0
          begin
            #$amount_pre = coinrpc.eth_call($txhash,'0x' + ($blockNumber-1).to_s(16))
            #$amount_cur = coinrpc.eth_call($txhash,'0x' + $blockNumber.to_s(16))
              #$amount_cur = coinrpc.eth_call($txhash,'latest')

              #$logger.info("amount_pre: " + $amount_pre)
              #$logger.info("amount_cur: " + $amount_cur)
          rescue
            $logger.info('[ERR]eth_call error')
            exit(1)
          end
          token_wei = $tokens[$to_addr]['COIN']

          #$balance_pre  = $amount_pre.hex.to_f / token_wei
          #$balance_cur  = $amount_cur.hex.to_f / token_wei
          $ether_receive = $innerValue.hex.to_f / token_wei

          #$logger.info("balance_pre: "     + $balance_pre.to_s)
          #$logger.info("balance_cur: "     + $balance_cur.to_s)
          #$logger.info("ether_receive: " + $ether_receive.to_s)

          #确定是充值交易
          $change  = 1 #$balance_cur - $balance_pre
          #$logger.info("change: " + $change.to_s)
          #$logger.info("gaslimit: " + $gasLimit.to_s)

          if($change > 0) #测试发现计算时候会有精度误差，因为如果使用绝对等于来判断，会有误判
            $to = "0x" + $innerAddrTo
            $assetType = $tokens[$to_addr]['COINTYPE'].to_s #addtodo
            $valueTem = $innerValue.hex.to_i
            $value = '0x' + $valueTem.to_s(16)
            $ether = $value.hex.to_f / token_wei #addtodo
            #$logger.info("to: " + $to)
            #$logger.info("assetType: "  + $assetType)
            #$logger.info("value: " + $value)
            #$logger.info("ether: "  + $ether.to_s)
          else
            $assetType = '-1'
            $logger.info("DDOS_TX: " + $txHash)
          end
          #exit(0)
        end
        #exit(1)
      end #
      # ***************************************  结束处理合约 新方式 *********************************

      #向数据库写入交易，受唯一性条件约束
      save_tx($txHash, $blockHash, $blockNumber, $from, $to, $value, $ether, $gasLimit, $gasPrice, $nonce, $assetType)

      #每存储50个区块，就更新一下数据库的lastLoadBlock，这个防止一次性没运行完，下次启动又要从来
      if $iHeight % 50 == 0
        update_one_baseinfo($iHeight, 'lastLoadBlock')
      end

      $iTx += 1
    end

    $iHeight += 1
  end #while 遍历区块加载交易结束

  #更新数据库的 lastLoadBlock
  if $isLoad.to_i == 1
    update_one_baseinfo($latestBlockHeight, 'lastLoadBlock')
  end

  $logger.debug('[DEBUG] *** 加载区块链交易结束 ***')
  $logger.debug('[DEBUG] *** 标记充值交易开始 ***')

  #***********************************************************  检索数据库，查找并标记充值交易  **********************************************

  #查找出该区间内的所有充值交易并标记
  if ($isScan.to_i == 1) && ($lastScanBlock < $latestBlockHeight)
    rslt = get_txs_include_account_db($lastScanBlock, $usersMax, $innerAddr)
    $logger.debug("[DEBUG] The rslt is #{rslt}")

    #循环标记为充值交易
    rslt.each do | row |
      $id = row[0]
      $address = row[1]
      $blockNumber = row[3]

      $logger.info("scan_id: " + $id)
      $logger.info("scan_to: " + $address)
      $logger.info("scan_blockNum: " + $blockNumber)

      #计算交易确认数
      $confirmation = $latestBlockHeight - $blockNumber.to_i + 1
      #$logger.info("scan_confir: " + $confirmation.to_s)

      #更新数据库标记为充值交易，更新确认数
      update_one_txs($id, $confirmation, 'confirmation')
      #$logger.info("depositTx_sql_ud: " + $sql_ud)

    end #while 标记充值交易结束

    #更新标记最后检索的标记 lastScanBlock
    update_one_baseinfo($latestBlockHeight, 'lastScanBlock')
  end #检索数据库查找充值交易结束

  $logger.debug('[DEBUG] *** 标记充值交易结束 ***')
  $logger.debug('[DEBUG] *** 向平台推送开始 ***')

  #*********************************************************  向交易平台推送消息  ****************************************************

  if ($isPost.to_i == 1)

    #从数据库读取所有未成功推送的交易
    rslt = get_no_post_txs
    $logger.debug("[DEBUG] The rslt is #{rslt}")
    #依次处理每一笔未成功推送的交易
    rslt.each do | row |

      $id = row[0]
      $txHash = row[1]
      $to = row[2]
      $value = row[3]
      $assetType = row[4].to_i
      $sendether = row[5].to_s

      $logger.info("post_id: " + $id)
      $logger.info("post_txHash: " + $txHash)
      $logger.info("post_to: " + $to)
      $logger.info("post_value: " + $value)
      $logger.info("post_ether: " + $sendether)

      #构造推送消息 现在改成了只对txid签名
      $sha3 = coinrpc.web3_sha3($txHash)
      #$logger.info("post_sha3: " + $sha3)

      #构造推送消息，附加sha3校验
      $senddata = ""

      #HTTP 推送消息
      #调用下面语句返回这个<Net::HTTPOK 200 OK readbody=true>
      #res = Net::HTTP.get_response(uri) # => String
      #$logger.info("post_res: " + res)
      $fPost = 0

      # 通用格式
      symbol = $token_type[$assetType]
      $senddata << "txhash=" << $txHash <<  "&to=" << $to << "&value=" << $sendether << "&symbol=" + symbol  << "&sign=" << $sha3
      $fPost = 1

      $logger.info("post_data: " + $url + $senddata)
      uri = URI($url + $senddata)
      res = Net::HTTP.get(uri) # => String
      $logger.info("post_res: " + res)
      if($fPost == 1)
        $resultCode = 0
	$resultMsg = ""
        begin
            $jsonhash = JSON.parse(res)
            $resultCode = $jsonhash['resultCode']
            $resultMsg = $jsonhash['resultMsg'] 
 	    #$logger.info($resultCode)
        rescue
            $logger.info("JSON::ParserError for HTTP Request,The server may have downtime")
        end

        #判断返回值，约定好对方返回1 或者 0
        if $resultCode == 10000
            $logger.info("post_deposit success,resultCode: " + $resultCode.to_s)
            # TODO 此处浪费数据库session
            update_many_txs($id, {"isPosted"=>1, 'resultCode'=>$resultCode})
        else
            $logger.error("post_http call failed ,resultMsg: "+ $resultMsg)
        end
      end #if(fPost == 1)

    end #while

  end #if ($isPost.to_i == 1)
  $logger.debug('[DEBUG] *** 向平台推送结束 ***')

  $logger.info("** END THE PROGRAM **")
end