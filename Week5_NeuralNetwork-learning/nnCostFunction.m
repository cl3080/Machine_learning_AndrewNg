function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m

% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


% X has dimension of 5000 by 400, (X has 5000 training examples,
% each example is a 20X20 grid of pixels "unrolled" into a 400-dimensional vector)
% Theta1 has dimension of 25 by 401, so one bias layer needs to be added to the input layer

a1 = [ones(m,1) X]; % add another bias column to X
z2 = Theta1 * a1'; % add weight matrix get z2, z2 is 25 by 5000
a2 = sigmoid(z2); % activation
a2 = [ones(1,m);a2]; % a2 is 25 by 5000 matrix, add one bias row to a2, now a2 has 26 rows and 5000 columns
z3 = Theta2 * a2; % add weight matrix get z3, z3 is a 10 by 5000 matrix
a3 = sigmoid(z3); % activation, output layer is a 10 by 5000 matrix

% Now the output layer contains either 0 or 1
% The original output is a 5000-dimensional vector with values from 0 to 9

% So the original y vector needs to be converted to either 0 or 1
y_t = zeros(num_labels,m);

for i = 1:m,
    y_t(y(i),i) = 1;
end;

% calculate the cost function
for n = 1:m,
    J += sum(-1*y_t(:,n).*log(a3(:,n)) - (1-y_t(:,n)).*log(1-a3(:,n)));
end;
J = J/m;

%add the regularization term
sum1 = sum(sum(Theta1(:,2:end).^2))
sum2 = sum(sum(Theta2(:,2:end).^2))
J = J + (sum1+sum2)*lambda/2/m

%implement backpropagation steps
Delta_1 = zeros(size(Theta1));
Delta_2 = zeros(size(Theta2));

for i = 1:m;
    delta3 = a3(:,i) - y_t(:,i); % compute the error for output layer
    delta2 = (Theta2'*delta3)(2:end,:).*sigmoidGradient(z2(:,i)); %remember to excule the bias layer
    Delta_2 += delta3 * a2(:,i)';
    Delta_1 += delta2 * a1(i,:);
end;
              
Theta1_grad = Delta_1/m;
Theta2_grad = Delta_2/m;
              
%Regularized Nerual network
Theta1_grad(:,2:end) = Theta1_grad(:,2:end).+lambda*Theta1(:,2:end)/m;
Theta2_grad(:,2:end) = Theta2_grad(:,2:end).+lambda*Theta2(:,2:end)/m;
            
% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
