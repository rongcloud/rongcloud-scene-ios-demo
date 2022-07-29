//
//  UIViewController+RoomContainer.swift
//  RCE
//
//  Created by hanxiaoqing on 2022/2/21.
//

import RCSceneRoom



extension RCRoomContainerViewController: RCRoomContainerAction {
    
    func enableSwitchRoom() {
        let roomList = self.roomList
        let currentIndex = self.currentIndex
        self.collectionView.scrollable = roomList[currentIndex].switchable
    }
    
    func disableSwitchRoom() {
        self.collectionView.scrollable = false
    }
    
    func switchRoom(_ room: RCSceneRoom) {
        if roomList[currentIndex].roomType == room.roomType {
            if let index = roomList.firstIndex(where: { $0.roomId == room.roomId }) {
                roomList[index] = room
                collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                            at: .centeredVertically,
                                            animated: false)
                currentIndex = index
                return
            }
        }
        roomList = [room]
        collectionView.reloadData()
        currentIndex = 0
        collectionView.scrollable = room.switchable
        switchRoom()
    }
}

extension RCRoomContainerViewController {
    /**
    func enableSwitchRoom() {
        collectionView.scrollable = roomList[currentIndex].switchable
    }

    func disableSwitchRoom() {
        collectionView.scrollable = false
    }
   
    func switchRoom(_ room: RCSceneRoom) {
        if roomList[currentIndex].roomType == room.roomType {
            if let index = roomList.firstIndex(where: { $0.roomId == room.roomId }) {
                roomList[index] = room
                collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                            at: .centeredVertically,
                                            animated: true)
                return
            }
        }
        roomList = [room]
        collectionView.reloadData()
        if currentIndex == 0 {
            switchRoom()
        } else {
            currentIndex = 0
        }
        collectionView.scrollable = roomList[currentIndex].switchable
    }
     */
}
