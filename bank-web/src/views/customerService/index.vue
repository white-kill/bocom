<template>
  <div class="customer-service">
    <nav-bar title="在线客服"></nav-bar>
    <div class="main">
      <img class="content" src="@/assets/image/home/customerService.png" alt="">
      <img class="bottom" src="@/assets/image/home/customerServiceBottom.png" alt="">
    </div>
  </div>
</template>
<script>
export default {
  name: "CustomerService",
  methods: {

  }
}
</script>
<style scoped lang="scss">
.customer-service {
  width: 100%;
  min-height: 100vh;
  background-color: #F4F4F4;

  .main {
    width: 100%;

    .content {
      width: 100%;
      display: block;
      height: 8.83rem;
    }
    .bottom {
      width: 100%;
      position: fixed;
      bottom: 0
    }
  }
}
</style>
