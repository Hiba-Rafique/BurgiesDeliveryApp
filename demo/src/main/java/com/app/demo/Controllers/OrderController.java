package com.app.demo.Controllers;

import com.app.demo.DTOs.OrderSummaryDTO;
import com.app.demo.models.*;
import com.app.demo.repository.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
@RestController
@RequestMapping("/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private CartRepository cartRepository;

    @Autowired
    private CartItemRepository cartItemRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private OrderItemRepository orderItemRepository;

    @PostMapping("/place/{customerId}")
    public ResponseEntity<?> placeOrder(@PathVariable Long customerId) {
        Optional<Customer> customerOpt = customerRepository.findById(customerId);
        if (!customerOpt.isPresent()) {
            return ResponseEntity.badRequest().body("Customer not found");
        }
        Customer customer = customerOpt.get();
        Cart cart = customer.getCart();

        if (cart == null || cart.getCartItems() == null || cart.getCartItems().isEmpty()) {
            return ResponseEntity.badRequest().body("Cart is empty");
        }

        // 1. Create Order
        Order order = new Order();
        order.setUser(customer); // Assuming Customer is a subtype of User
        order.setStatus(OrderStatus.CONFIRMED); // Or any default status
        order.setDate(LocalDateTime.now());
        List<OrderItem> orderItems = new ArrayList<>();

        for (CartItem cartItem : cart.getCartItems()) {
            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setMenuItem(cartItem.getMenuItem());
            orderItem.setQuantity(cartItem.getQuantity());
            orderItems.add(orderItem);
        }

        order.setOrderItems(orderItems);
        orderRepository.save(order); // cascade should save OrderItems

        // 2. Clear cart
        cartItemRepository.deleteAll(cart.getCartItems());
        cart.getCartItems().clear();
        cartRepository.save(cart);

        return ResponseEntity.ok("Order placed successfully with ID: " + order.getId());
    }

    @GetMapping("/history/{customerId}")
    public ResponseEntity<?> getOrderHistory(@PathVariable Long customerId) {
        Optional<Customer> customerOpt = customerRepository.findById(customerId);
        if (!customerOpt.isPresent()) {
            return ResponseEntity.badRequest().body("Customer not found");
        }

        Customer customer = customerOpt.get();

        if (customer.getOrders() == null || customer.getOrders().isEmpty()) {
            return ResponseEntity.ok("No orders found");
        }

        List<OrderSummaryDTO> history = customer.getOrders()
                .stream()
                .map(OrderSummaryDTO::new)
                .toList();

        return ResponseEntity.ok(history);
    }

    @GetMapping("/incomplete")
    public ResponseEntity<?> getIncompleteOrders() {
        List<Order> incompleteOrders = orderRepository.findByStatusNot(OrderStatus.COMPLETED);

        if (incompleteOrders.isEmpty()) {
            return ResponseEntity.ok("No incomplete orders found.");
        }

        List<Map<String, Object>> response = incompleteOrders.stream().map(order -> {
            Map<String, Object> orderMap = new HashMap<>();
            orderMap.put("orderId", order.getId());
            orderMap.put("date", order.getDate());
            orderMap.put("status", order.getStatus());

            // Fetch user and treat as customer if role is CUSTOMER
            User user = order.getUser();
            if (user != null && user.getRole() == Role.CUSTOMER) {
                Map<String, Object> customerInfo = new HashMap<>();
                customerInfo.put("firstName", user.getFirstName());
                customerInfo.put("lastName", user.getLastName());
                customerInfo.put("email", user.getEmail());
                customerInfo.put("phoneNumber", user.getPhoneNum());
//                customerInfo.put("address", user.getAddress());
                orderMap.put("customer", customerInfo);
            }

            // Items
            List<Map<String, Object>> itemList = new ArrayList<>();
            for (OrderItem item : order.getOrderItems()) {
                Map<String, Object> itemMap = new HashMap<>();
                itemMap.put("id", item.getId());
                itemMap.put("quantity", item.getQuantity());

                MenuItem menuItem = item.getMenuItem();
                if (menuItem != null) {
                    Map<String, Object> menuItemMap = new HashMap<>();
                    menuItemMap.put("id", menuItem.getId());
                    menuItemMap.put("name", menuItem.getName());
                    menuItemMap.put("price", menuItem.getPrice());
                    menuItemMap.put("description", menuItem.getDescription());
                    menuItemMap.put("image", menuItem.getImage());
                    itemMap.put("menuItem", menuItemMap);
                }

                itemList.add(itemMap);
            }

            orderMap.put("items", itemList);

            return orderMap;
        }).toList();

        return ResponseEntity.ok(response);
    }


}


