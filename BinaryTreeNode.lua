local BinaryTreeNode = {}
BinaryTreeNode.__index = BinaryTreeNode

function BinaryTreeNode.new(Data)
    local self = {}

    self.Left = ""
    self.Right = ""

    self.Data = Data

    return self
end

function BinaryTreeNode:PrintNode(Node)
    print(Node.Data)
end

local root = BinaryTreeNode.new(27)

BinaryTreeNode:PrintNode(root)

return BinaryTreeNode
