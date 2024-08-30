// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/musicManagement.sol"; // 路径根据实际情况调整

contract MusicManagementTest is Test {
    musicManagement public musicContract;
    address public creator;

    function setUp() public {
        musicContract = new musicManagement();
        creator = address(0x123); // 模拟一个音乐创作者地址
    }

    function testRegisterMusic() public {
        vm.startPrank(creator);

        string memory title = "My First Song";
        string memory fileHash = "QmT5NvUtoM5n4gM5U1C5Z73kmE5T5tQJ4GRz1zrRsL4M6V";
        string memory version = "v1.0";

        // 注册音乐
        musicContract.registerMusic(title, fileHash, version);

        // 检查音乐是否被注册
        (
            string memory registeredTitle,
            address registeredCreator,
            uint256 timestamp,
            string[] memory fileHashes,
            string[] memory versions
        ) = musicContract.getMusicInfo(1);

        assertEq(registeredTitle, title);
        assertEq(registeredCreator, creator);
        assertEq(fileHashes[0], fileHash);
        assertEq(versions[0], version);
        assertGt(timestamp, 0); // 确保时间戳是有效的

        vm.stopPrank();
    }

    function testRegisterMusicFailsWithoutTitle() public {
        vm.startPrank(creator);

        string memory fileHash = "QmT5NvUtoM5n4gM5U1C5Z73kmE5T5tQJ4GRz1zrRsL4M6V";
        string memory version = "v1.0";

        vm.expectRevert(musicManagement.MM_RM_TitleIsEmpty.selector);
        musicContract.registerMusic("", fileHash, version);

        vm.stopPrank();
    }

    function testRegisterMusicFailsIfFileHashExists() public {
        vm.startPrank(creator);

        string memory title = "My First Song";
        string memory fileHash = "QmT5NvUtoM5n4gM5U1C5Z73kmE5T5tQJ4GRz1zrRsL4M6V";
        string memory version = "v1.0";

        musicContract.registerMusic(title, fileHash, version);

        vm.expectRevert(musicManagement.MM_RM_FileHashExisted.selector);
        musicContract.registerMusic("Another Song", fileHash, "v2.0");

        vm.stopPrank();
    }

    function testAddVersion() public {
        vm.startPrank(creator);

        string memory title = "My First Song";
        string memory fileHash = "QmT5NvUtoM5n4gM5U1C5Z73kmE5T5tQJ4GRz1zrRsL4M6V";
        string memory version = "v1.0";

        musicContract.registerMusic(title, fileHash, version);

        string memory newFileHash = "QmT5NvUtoM5n4gM5U1C5Z73kmE5T5tQJ4GRz1zrRsL4M7W";
        string memory newVersion = "v2.0";

        // 添加版本
        musicContract.addVersion(1, newFileHash, newVersion);

        (,,, string[] memory fileHashes, string[] memory versions) = musicContract.getMusicInfo(1);

        assertEq(fileHashes[1], newFileHash);
        assertEq(versions[1], newVersion);

        vm.stopPrank();
    }

    function testAddVersionFailsIfNotCreator() public {
        address anotherUser = address(0x456);
        vm.startPrank(anotherUser);

        string memory newFileHash = "QmT5NvUtoM5n4gM5U1C5Z73kmE5T5tQJ4GRz1zrRsL4M8X";
        string memory newVersion = "v2.0";

        vm.expectRevert(musicManagement.MM_AddVer_OnlyCreatorCanAddVersions.selector);
        musicContract.addVersion(1, newFileHash, newVersion);

        vm.stopPrank();
    }

    function testGetMusicInfoFailsForInvalidId() public {
        vm.expectRevert(musicManagement.MM_GetInfo_InvalidMusicId.selector);
        musicContract.getMusicInfo(999);
    }
}
