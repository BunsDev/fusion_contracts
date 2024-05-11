// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

abstract contract TeamManager {
    address internal constant SENTINEL_MEMBER = address(0x1);

    mapping(address => address) internal members;

    constructor() {
        members[SENTINEL_MEMBER] = SENTINEL_MEMBER;
    }

    function addMember(address member) internal {
        require(
            member != address(0) || member != SENTINEL_MEMBER,
            "Invalid member"
        );
        require(members[member] == address(0), "Member already exists");
        members[member] = members[SENTINEL_MEMBER];
        members[SENTINEL_MEMBER] = member;
    }

    function removeMember(address prevMember, address member) internal {
        require(
            member != address(0) || member != SENTINEL_MEMBER,
            "Invalid member"
        );
        require(members[prevMember] == member, "Invalid member");
        members[prevMember] = members[member];
        members[member] = address(0);
    }

    function isMember(address member) public view returns (bool) {
        return SENTINEL_MEMBER != member && members[member] != address(0);
    }

    function getMembersPaginated(
        address start,
        uint256 pageSize
    ) public view returns (address[] memory array, address next) {
        require(start != SENTINEL_MEMBER && !isMember(start), "Invalid start");
        require(pageSize != 0, "Invalid page size");
        array = new address[](pageSize);

        uint256 moduleCount = 0;
        next = members[start];
        while (
            next != address(0) &&
            next != SENTINEL_MEMBER &&
            moduleCount < pageSize
        ) {
            array[moduleCount] = next;
            next = members[next];
            moduleCount++;
        }

        if (next != SENTINEL_MEMBER) {
            next = array[moduleCount - 1];
        }
        assembly {
            mstore(array, moduleCount)
        }
    }
}
