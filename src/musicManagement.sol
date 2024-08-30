// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract musicManagement {
    uint256 private _musicCounts;

    struct MusicInfo {
        string title;
        address creator;
        uint256 timestamp;
        string[] fileHashes;
        string[] versions;
    }

    mapping(uint256 musicid => MusicInfo) public musicRegistry;
    mapping(string => uint256) public hashToMusicId;

    error MM_RM_TitleIsEmpty();
    error MM_RM_FileHashIsEmpty();
    error MM_RM_FileHashExisted();
    error MM_AddVer_InvalidMusicId();
    error MM_AddVer_OnlyCreatorCanAddVersions();
    error MM_AddVer_FileHashExisted();
    error MM_GetInfo_InvalidMusicId();

    event MusicRegistered(uint256 indexed musicId, string title, address indexed creator, uint256 timestamp);
    event VersionAdded(uint256 indexed musicId, string fileHash, string version);

    function registerMusic(string memory _title, string memory _fileHash, string memory _version) public {
        if (bytes(_title).length <= 0) {
            revert MM_RM_TitleIsEmpty();
        }

        if (bytes(_fileHash).length <= 0) {
            revert MM_RM_FileHashIsEmpty();
        }
        if (hashToMusicId[_fileHash] != 0) {
            revert MM_RM_FileHashExisted();
        }

        _musicCounts++;
        uint256 newMusicId = _musicCounts;

        MusicInfo storage newMusic = musicRegistry[newMusicId];
        newMusic.title = _title;
        newMusic.creator = msg.sender;
        newMusic.timestamp = block.timestamp;
        newMusic.fileHashes.push(_fileHash);
        newMusic.versions.push(_version);

        hashToMusicId[_fileHash] = newMusicId;

        emit MusicRegistered(newMusicId, _title, msg.sender, block.timestamp);
        emit VersionAdded(newMusicId, _fileHash, _version);
    }

    function addVersion(uint256 _musicId, string memory _fileHash, string memory _version) public {
        if (_musicId <= 0 && _musicId > _musicCounts) {
            revert MM_AddVer_InvalidMusicId();
        }
        if (musicRegistry[_musicId].creator != msg.sender) {
            revert MM_AddVer_OnlyCreatorCanAddVersions();
        }
        if (hashToMusicId[_fileHash] != 0) {
            revert MM_AddVer_FileHashExisted();
        }

        MusicInfo storage music = musicRegistry[_musicId];
        music.fileHashes.push(_fileHash);
        music.versions.push(_version);

        hashToMusicId[_fileHash] = _musicId;

        emit VersionAdded(_musicId, _fileHash, _version);
    }

    function getMusicInfo(uint256 _musicId)
        public
        view
        returns (
            string memory title,
            address creator,
            uint256 timestamp,
            string[] memory fileHashes,
            string[] memory versions
        )
    {
        if (_musicId <= 0 && _musicId > _musicCounts) {
            revert MM_GetInfo_InvalidMusicId();
        }
        MusicInfo storage music = musicRegistry[_musicId];
        return (music.title, music.creator, music.timestamp, music.fileHashes, music.versions);
    }
}
